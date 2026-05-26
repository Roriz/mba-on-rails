#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import json
import re
from presidio_analyzer import AnalyzerEngine
from presidio_analyzer.nlp_engine import NlpEngineProvider

# Explicitly configure NLP Engine to use the downloaded en_core_web_sm model
# This prevents Presidio from trying to auto-download the larger en_core_web_lg model via pip
nlp_configuration = {
    "nlp_engine_name": "spacy",
    "models": [{"lang_code": "en", "model_name": "en_core_web_sm"}]
}
provider = NlpEngineProvider(nlp_configuration=nlp_configuration)
nlp_engine = provider.create_engine()
analyzer = AnalyzerEngine(nlp_engine=nlp_engine)

# Common professional title roots for Portuguese stemming/neutralization
# Maps (regex matching the full word including optional plural/gender suffixes) -> root
STEM_PATTERNS = [
    (re.compile(r'\bcoordenador(a)?(es|s)?\b', re.IGNORECASE), "coordenad"),
    (re.compile(r'\bfacilitador(a)?(es|s)?\b', re.IGNORECASE), "facilit"),
    (re.compile(r'\bescritor(a)?(es|s)?\b', re.IGNORECASE), "escrit"),
    (re.compile(r'\bdiretor(a)?(es|s)?\b', re.IGNORECASE), "diret"),
    (re.compile(r'\bprofessor(a)?(es|s)?\b', re.IGNORECASE), "profess"),
    (re.compile(r'\bprogramador(a)?(es|s)?\b', re.IGNORECASE), "programad"),
    (re.compile(r'\bdesenvolvedor(a)?(es|s)?\b', re.IGNORECASE), "desenvolved"),
    (re.compile(r'\badministrador(a)?(es|s)?\b', re.IGNORECASE), "administrad"),
]

def neutralize_portuguese_titles(text):
    """
    Applies gender neutralization/stemming rules to Portuguese professional titles as per the slides.
    E.g. "facilitadora" -> "facilit", "coordenador" -> "coordenad", "escritor" -> "escrit".
    """
    neutralized = text
    changes = []
    
    for regex, root in STEM_PATTERNS:
        # We need to find all matches using finditer to capture groups correctly
        # Using a list to avoid modifying text while iterating
        matches = list(regex.finditer(neutralized))
        for match in matches:
            orig = match.group(0)
            plural = match.group(2)
            target = root
            if plural:
                target += 's'
            
            # Perform strict word boundary replacement for safety
            word_regex = re.compile(r'\b' + re.escape(orig) + r'\b', re.IGNORECASE)
            neutralized, count = word_regex.subn(target, neutralized)
            if count > 0:
                changes.append({"original": orig, "neutralized": target})
                
    return neutralized, changes

def process_request(req):
    action = req.get("action")
    text = req.get("text", "")
    
    if action == "anonymize":
        # 1. Analyze text for standard PII entities
        results = analyzer.analyze(
            text=text,
            language="en"
        )
        
        # 2. Filter out overlapping/nested entities (keep only outer/larger ones)
        # Sort by start position ascending, and end position descending to process outer items first
        sorted_by_position = sorted(results, key=lambda x: (x.start, -x.end))
        filtered_results = []
        last_end = -1
        for item in sorted_by_position:
            if item.start >= last_end:
                filtered_results.append(item)
                last_end = item.end
        
        # 3. Sequential custom token replacement for precise mapping
        # Sort filtered results by start position in reverse order to replace without changing offsets for earlier items
        sorted_results = sorted(filtered_results, key=lambda x: x.start, reverse=True)
        
        pii_items = []
        entity_counters = {}
        anonymized_text = text
        
        for item in sorted_results:
            entity = item.entity_type
            # We want unique index starting from 1
            entity_counters[entity] = entity_counters.get(entity, 0) + 1
            idx = entity_counters[entity]
            token = f"<{entity}_{idx}>"
            
            original_value = text[item.start:item.end]
            anonymized_text = anonymized_text[:item.start] + token + anonymized_text[item.end:]
            
            pii_items.append({
                "original": original_value,
                "token": token,
                "entity_type": entity
            })
            
        # Reverse pii_items to be in chronological order
        pii_items.reverse()
        
        # 4. Apply Portuguese Professional Title Gender Neutralization
        neutralized_text, title_changes = neutralize_portuguese_titles(anonymized_text)
        
        return {
            "success": True,
            "original_text": text,
            "anonymized_text": anonymized_text,
            "neutralized_text": neutralized_text,
            "pii_items": pii_items,
            "title_changes": title_changes
        }
    else:
        return {"success": False, "error": f"Unknown action: {action}"}

def main():
    # Read line-by-line from stdin for JSON-RPC style interface
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
            res = process_request(req)
            print(json.dumps(res), flush=True)
        except Exception as e:
            err_res = {"success": False, "error": str(e)}
            print(json.dumps(err_res), flush=True)

if __name__ == "__main__":
    main()
