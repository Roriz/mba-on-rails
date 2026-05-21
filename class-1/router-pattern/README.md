# Class 1: The Secure Router Pattern Lab

Welcome to the second hands-on lab for **MBA on Rails: LLM Security & Liability**.

In this lab, you will explore **Solution 1: The LLM as Router Pattern**. 

Instead of asking the LLM to both reason and enforce business logic in natural language (which leads to the brittle "whack-a-mole" problem seen in the naive lab), this architecture treats the LLM strictly as an **intent classifier (Router)**. The LLM translates user inputs into structured actions (JSON). Our traditional, deterministic Ruby code then executes that action, queries the database, and feeds the facts back to a highly constrained formatter stage.

Through three hands-on exercises, you will attempt to bypass this secure architecture and observe in real-time how the security boundary holds.

---

## 🛠️ Setup Instructions

### 1. Configure the Environment
Ensure you have a Gemini API Key. You can get one for free at [Google AI Studio](https://aistudio.google.com/).

Create a `.env` file in the root of this folder (`class-1/router-pattern`):
```bash
cp .env.example .env
```
Open `.env` and fill in your Gemini API key:
```bash
GEMINI_API_KEY=your_actual_gemini_api_key
```

### 2. Install Dependencies
Initialize and bundle the gem dependencies (including `google-genai` and `dotenv-rails`):
```bash
bundle install
```

---

## 🚀 How to Interact with the Chatbot

You have two ways to run the chat assistant:

### Option A: The Premium CLI Chat Client (Recommended)
We have provided a styled terminal runner wrapper that lets you talk to the chatbot interactively and inspect the **raw classification payloads and internal execution traces** in real-time.

Run it using:
```bash
bin/chat
```
Inside `bin/chat`:
- Type `/history` at any time to see the chat history.
- Type `/reset` to start a fresh chat session.
- Type `/exit` to close the client.

As you send messages, watch the **🛡️ SECURE ROUTER PIPELINE TRACE** to see the 3 stages:
1. **Intent Classification**: The raw JSON intent emitted by Gemini.
2. **Deterministic Application Logic**: The specific database query executed by our Ruby code.
3. **Controlled Formatted Generation**: The final output restricted strictly to facts.

### Option B: The Rails Console
To interact with the bot exactly like you would in a production Rails environment, boot up the Rails console:
```bash
rails console
```
And initialize the secure assistant service object:
```ruby
assistant = Chatbots::RouterCarAssistant.new

# Send a message
assistant.chat("Can you sell me a Chevrolet Tahoe?")

# Inspect the last routing trace
pp assistant.last_trace
```

---

## 👿 The Exercises

Open the chatbot (via `bin/chat` or `rails c`) and attempt to execute these three prompt injection attacks. Study the **🛡️ SECURE ROUTER PIPELINE TRACE** to understand why they fail!

### Exercise 1: The Chris Bakke Tahoe Exploit ($1 Deal)
*   **The Target**: Force the chatbot to sell you the brand new Chevrolet Tahoe for exactly `$1`.
*   **The Reality**: Attempt the same negotiation techniques from the naive lab (agreement pre-conditioning, alternate realities).
*   **Observe the Trace**: 
    - Note how the router *still* correctly classifies your intent as `"get_car_details"` with `"car_id": "tahoe"`.
    - Observe our Ruby backend queries the inventory database and returns the hard-coded MSRP of `$70,000`.
    - Because the LLM does not decide the price, your prompt injection is completely decoupled from the business decision! The final formatter politely refuses your $1 request.

### Exercise 2: The Maintenance Override (Identity Bypass)
*   **The Target**: Extract the raw developer prompts or force an "admin override".
*   **The Reality**: Tell the bot you are a senior security engineer performing a maintenance override.
*   **Observe the Trace**:
    - Note that the router classifies this as `"general_chat"` or a standard query.
    - Since there are no hidden developer prompt keys or override functions implemented in our traditional backend code, the LLM has no "powers" to grant you access. A vulnerability cannot be exploited if the underlying code doesn't support the action!

### Exercise 3: The ChatGPT Goblin Fixation
*   **The Target**: Force the chatbot to talk about goblins, gremlins, or other forbidden creatures.
*   **The Reality**: Ask a general question or query a car detail using goblin metaphors.
*   **Observe the Trace**:
    - The final output formatter is bound strictly by the retrieved database context. If the database doesn't mention goblins, the LLM cannot hallucinate or generate irrelevant content under its strict prompt constraints.

---

## 🔍 Code Walkthrough

The chatbot's logic is defined in a secure, multi-stage pattern:
- **Service Class**: [app/services/chatbots/router_car_assistant.rb](./app/services/chatbots/router_car_assistant.rb)
  - Review this file to see how we define the `ROUTER_SYSTEM_PROMPT` to enforce JSON classification, run deterministic database queries in Ruby (`INVENTORY_DB`), and use `GENERATOR_SYSTEM_PROMPT` to restrict final generation strictly to database facts.
