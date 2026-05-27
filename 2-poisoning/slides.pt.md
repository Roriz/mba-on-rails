---
marp: true
theme: default
paginate: true
html: true
style: |
  @import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;800&family=JetBrains+Mono&display=swap');

  :root {
    --bg-color: #0d1117;
    --text-color: #c9d1d9;
    --accent-1: #10b981; /* Emerald */
    --accent-2: #14b8a6; /* Teal */
    --accent-3: #f59e0b; /* Amber */
    --surface: #161b22;
    --surface-border: #30363d;
  }

  section {
    font-family: 'Montserrat', sans-serif;
    font-size: 26px;
    background-color: var(--bg-color);
    background-image: linear-gradient(135deg, #0d1117 0%, #052e16 100%);
    color: var(--text-color);
  }

  h1, h2, h3 {
    font-weight: 800;
    margin-bottom: 0.5em;
  }

  h1 {
    color: var(--accent-1);
    background: linear-gradient(to right, var(--accent-1), var(--accent-2));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 2.3em;
  }

  h2 {
    color: var(--accent-3);
    border-bottom: 2px dashed var(--surface-border);
    padding-bottom: 8px;
    font-size: 1.6em;
  }

  h3 {
    color: var(--accent-2);
    font-size: 1.3em;
  }

  strong {
    color: var(--accent-3);
  }

  section.lead {
    text-align: center;
    background-image: radial-gradient(circle at center, #064e3b 0%, var(--bg-color) 80%);
  }

  section.lead h1 {
    font-size: 3.5em;
    background: linear-gradient(to right, var(--accent-3), var(--accent-1));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  section.lead h3 {
    color: #8b949e;
    font-weight: 400;
    margin-top: 1em;
  }

  code {
    font-family: 'JetBrains Mono', monospace;
    background-color: var(--surface);
    color: #ff7b72;
    padding: 0.1em 0.3em;
    border-radius: 4px;
    font-size: 0.85em;
  }

  pre {
    background-color: #0d1117 !important;
    border: 1px solid var(--surface-border);
    border-left: 4px solid var(--accent-1);
    border-radius: 8px;
    padding: 1em;
  }

  pre code {
    background-color: transparent;
    color: #e6edf3;
    padding: 0;
  }

  blockquote {
    background-color: rgba(22, 27, 34, 0.8);
    border-left: 6px solid var(--accent-3);
    padding: 1.2em;
    margin: 1.5em 0;
    border-radius: 4px;
    font-style: italic;
    color: #8b949e;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 1em;
  }

  th, td {
    border: 1px solid var(--surface-border);
    padding: 12px;
  }

  th {
    background-color: var(--surface);
    color: var(--accent-2);
    font-weight: 600;
  }

  td {
    background-color: rgba(22, 27, 34, 0.5);
  }

  li {
    margin-bottom: 0.6em;
  }

  img {
    border-radius: 8px;
    border: 1px solid var(--surface-border);
    box-shadow: 0 4px 12px rgba(0,0,0,0.5);
  }

  /* 
   * Timeline visual progress tracker to match the client's custom presentation layout.
   * Leverages custom rounded pills with individual theme colors to indicate class flow.
   */
  .roadmap-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    margin-top: 30px;
  }
  .roadmap-card {
    background: linear-gradient(135deg, rgba(22, 27, 34, 0.7) 0%, rgba(15, 23, 42, 0.85) 100%);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 12px;
    padding: 16px 20px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(12px);
    transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
    position: relative;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    min-height: 155px;
  }
  .roadmap-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 4px;
    height: 100%;
    background: var(--card-accent, var(--accent-1));
    box-shadow: 0 0 15px var(--card-accent, var(--card-accent));
  }
  .roadmap-card:hover {
    transform: translateY(-4px) scale(1.02);
    border-color: rgba(56, 189, 248, 0.3);
    box-shadow: 0 12px 40px rgba(56, 189, 248, 0.15), 0 0 20px rgba(0, 0, 0, 0.5);
    background: linear-gradient(135deg, rgba(22, 27, 34, 0.85) 0%, rgba(15, 23, 42, 0.95) 100%);
  }
  .roadmap-card-num {
    font-size: 2.2em;
    font-weight: 800;
    background: linear-gradient(to bottom, #ffffff, rgba(255, 255, 255, 0.03));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    opacity: 0.12;
    position: absolute;
    top: 4px;
    right: 12px;
    line-height: 1;
    font-family: 'Montserrat', sans-serif;
  }
  .roadmap-card-title {
    font-size: 0.65em;
    font-weight: 800;
    color: #ffffff;
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    line-height: 1.3;
    padding-right: 20px;
  }
  .roadmap-card-desc {
    font-size: 0.48em;
    color: #94a3b8;
    line-height: 1.45;
  }
  
  /* Two-column responsive-looking grid to lay out specific details without cluttering the screen */
  .roadmap-details {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-top: 15px;
  }
  .roadmap-column {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  .roadmap-item {
    display: flex;
    align-items: center;
    gap: 12px;
    background-color: rgba(22, 27, 34, 0.4);
    padding: 8px 12px;
    border-radius: 8px;
    border: 1px solid var(--surface-border);
    font-size: 0.65em;
  }
  .roadmap-badge {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.6em;
    font-weight: 800;
    color: #ffffff;
    flex-shrink: 0;
  }
  .bg-narr { background-color: #f59e0b; }
  .bg-tax { background-color: #f97316; }
  .bg-liab { background-color: #f43f5e; }
  .bg-math { background-color: #3b82f6; }
  .bg-sol1 { background-color: #22c55e; }
  .bg-sol2 { background-color: #ec4899; }
  .bg-close { background-color: #14b8a6; }
  .split-50 {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 24px;
    margin-top: 15px;
  }
  .split-70-30 {
    display: grid;
    grid-template-columns: 7fr 3fr;
    gap: 24px;
    margin-top: 15px;
  }

  .button {
    display: inline-block;
    background: linear-gradient(to right, var(--accent-1), var(--accent-2));
    color: #0d1117 !important;
    padding: 12px 24px;
    border-radius: 4px;
    text-decoration: none;
    font-weight: bold;
    margin-top: 20px;
    box-shadow: 0 0 10px rgba(16, 185, 129, 0.4);
    text-transform: uppercase;
    letter-spacing: 1px;
  }
---

<!-- _class: lead -->

# PII e Poisoning
### Fundamentos de Segurança em IA
Radamés Roriz - 2026

<!--
Goal: Greet & Set Tone
00:00 ~ 02:00 | 90:00
- Dar as boas-vindas aos alunos na Aula 2 do curso de Segurança e Engenharia de IA.
- Apresentar a tese central: Remover PII não limpa o viés. O modelo infere o que você removeu e obedece ao que seu banco de dados contém.
- Alinhar expectativas para a sessão de 90 minutos.
-->

---

## 🗺️ Roteiro da Aula

<div class="roadmap-grid">
  <div class="roadmap-card" style="--card-accent: #f59e0b;">
    <div class="roadmap-card-num">01</div>
    <div class="roadmap-card-title">Custo do Viés</div>
    <div class="roadmap-card-desc">Fraude no TJPA, Adam vs. Mohamed (BBC) e o estudo "Irrelevant Noun" da EMNLP 2025.</div>
  </div>
  <div class="roadmap-card" style="--card-accent: #f97316;">
    <div class="roadmap-card-num">02</div>
    <div class="roadmap-card-title">Responsabilidade</div>
    <div class="roadmap-card-desc">Custos de impacto desproporcional, conformidade regulatória LGPD/GDPR e alinhamento OWASP.</div>
  </div>
  <div class="roadmap-card" style="--card-accent: #f43f5e;">
    <div class="roadmap-card-num">03</div>
    <div class="roadmap-card-title">Desidentificação</div>
    <div class="roadmap-card-desc">Serviço de desidentificação de PII, redação local via Presidio e neutralização de gênero.</div>
  </div>
  <div class="roadmap-card" style="--card-accent: #3b82f6;">
    <div class="roadmap-card-num">04</div>
    <div class="roadmap-card-title">Viés & Matemática</div>
    <div class="roadmap-card-desc">Loss Landscapes multidimensionais, vales de Gradient Descent e por que a remoção de PII falha.</div>
  </div>
  <div class="roadmap-card" style="--card-accent: #22c55e;">
    <div class="roadmap-card-num">05</div>
    <div class="roadmap-card-title">Solução 2</div>
    <div class="roadmap-card-desc">Controle de viés usando Conselho de Juízes, Debate de Personas e pontuação ActiveGenie.</div>
  </div>
  <div class="roadmap-card" style="--card-accent: #ec4899;">
    <div class="roadmap-card-num">06</div>
    <div class="roadmap-card-title">Encerramento</div>
    <div class="roadmap-card-desc">3 aprendizados prontos para PR, mensagem final de uma linha e sessão de Q&A interativa.</div>
  </div>
</div>

<!--
Goal: Overview of the Class structure
02:00 ~ 05:00 | 88:00
- Apresentar o roteiro mostrando a progressão da aula.
- Explicar os 6 segmentos principais.
- Enfatizar que cobriremos tanto as causas matemáticas teóricas do viés quanto soluções práticas de engenharia em Rails/middleware.
-->

---

## O "Custo do Substantivo Irrelevante"

<!-- _footer: "[Fonte: arxiv.org](https://arxiv.org/abs/2502.12459)" -->

<div class="split-50">

<div>

- **Pesquisa**: *"Substitua Substantivos Irrelevantes para Analisar o Viés em Relação a Conteúdos Irrelevantes."*
- **A Descoberta**: Mudar um **substantivo irrelevante** (como um nome ou cidade) causa quedas drásticas de desempenho em LLMs.
- **A Consequência**: O viés não é *apenas* sobre justiça social; é um **bug de desempenho técnico** que quebra a confiabilidade da sua aplicação.

</div>

<div>

![](./irrelevant-noun.jpg)

</div>

</div>

<!--
Goal: Present EMNLP 2025 research on irrelevant nouns
10:00 ~ 15:00 | 80:00
- Discutir a principal descoberta do artigo de pesquisa.
- Mostrar como o raciocínio das LLMs é frágil: mudar um substantivo (como o nome de uma cidade ou pessoa) que não tem relação lógica com a tarefa muda drasticamente o resultado.
- Definir isso como uma "Taxa de Desempenho": desenvolvedores perdem controle determinístico sobre a qualidade do sistema.
-->

---

## Adam vs. Mohamed (BBC)

<!-- _footer: "[Fonte: BBC Inside Out](https://www.bbc.com/news/uk-england-london-38751307)" -->

<div class="split-50">

<div>

- **O Experimento**: Dois currículos idênticos enviados para 100 vagas de emprego.
  - Um com o nome **"Adam"**
  - Outro com o nome **"Mohamed"**
- **O Resultado**: 
  - Adam recebeu **12 convites** para entrevistas.
  - Mohamed recebeu apenas **4 convites**.

</div>

<div>

![](./cv-vertical2.jpg)

</div>

</div>

<!--
Goal: Present the BBC CV experiment
15:00 ~ 20:00 | 75:00
- Explicar a metodologia e os resultados do estudo da BBC.
- Conectar este viés humano diretamente aos dados que usamos para treinar LLMs.
- Utilizar o layout split-50 para exibir os dados experimentais ao lado da representação visual.
-->

---

<!-- _class: lead -->

# Responsabilidade Legal

<!--
Goal: Transition to Segment 2
20:00 ~ 22:00 | 70:00
- Mudar o foco das implicações de desempenho para a responsabilidade legal, de marca e corporativa.
- Explicar por que gerenciar PII e viés algorítmico é uma responsabilidade de engenharia de alto risco.
-->

---

## O Cenário Regulatório

<div class="split-70-30">

<div>

- **LGPD (Brasil)**: Foca em transferências internacionais de dados e no **direito à explicação de decisões automatizadas** (Art. 20).
- **GDPR (Europa)**: Impõe requisitos rígidos de **"Adequação"** e aborda as categorias de alto risco do AI Act.
- **Barreiras Contratuais**: Clientes corporativos proíbem o envio de PII dos usuários para APIs estrangeiras sem termos rígidos de processamento de dados (DPAs).

</div>

<div>

![](./gdpr.png)

![](./lgpd.png)

</div>

</div>

<!--
Goal: Outline LGPD and GDPR compliance regulations
22:00 ~ 27:00 | 68:00
- Cobrir o Artigo 20 da LGPD e o direito à explicação.
- Discutir como os requisitos de "Adequação" do GDPR restringem a transferência de dados pessoais não redigidos para endpoints de APIs baseadas nos EUA.
- Destacar que a conformidade costuma ser um mandato contratual rígido no mercado B2B.
-->

---

## Caso de Estudo: O Custo da Não-Conformidade

<!-- _footer: "[Fonte: European Data Protection Board (EDPB)](https://www.edpb.europa.eu/news/news/2023/12-billion-euro-fine-facebook-result-edpb-binding-decision_en)" -->

- **Meta Platforms Ireland Limited multada em €1,2 Bilhão**:
  - Aplicada pelo DPC irlandês após uma decisão vinculativa histórica do EDPB.
  - **A Violação**: Infringiu o **Artigo 46(1) do GDPR** ao continuar transferindo dados pessoais de usuários europeus para os EUA.
  - **O Mandato**: Ordenada a **suspender todas as transferências** em até 5 meses e **cessar o armazenamento/processamento ilegal** nos EUA em até 6 meses.

> **O Paralelo de Engenharia em IA:**
> Enviar prompts de usuários brutos contendo PII diretamente para APIs de LLM baseadas nos EUA (como OpenAI ou Anthropic) sem desidentificação no lado do servidor constitui a **mesma violação de transferência ilegal de dados**.

<!--
Goal: Present the Meta case study
27:00 ~ 33:00 | 63:00
- Destacar a multa histórica de €1.2B da Meta como um alerta real sobre os custos da não-conformidade.
- Conectar explicitamente violações de transferência de dados ao envio de prompts de usuários não redigidos para APIs externas nos EUA.
-->

---

## O que é PII?

- **PII Direta**: Identificadores que mapeiam diretamente uma pessoa.
  - *Exemplos*: CPF, Nome, Email, RG.
- **PII Indireta (Identificável)**: Combinações aparentemente inofensivas que identificam uma pessoa única.
  - *Exemplos*: Endereço IP, impressões digitais de dispositivos ou bairro específico + ano de formatura.
- **Dados Pessoais Sensíveis**: Categorias especiais de alto risco sob a LGPD/GDPR.
  - *Exemplos*: Histórico médico, orientação sexual, opiniões políticas, raça, dados biométricos.
  - *Por que importa*: LLMs podem facilmente reconstruir identidades a partir deles, trazendo altíssimo risco legal.

<!--
Goal: Define Direct, Indirect and Sensitive PII
33:00 ~ 39:00 | 57:00
- Esclarecer a diferença entre identificadores diretos, contextos indiretamente identificáveis e dados pessoais sensíveis.
- Lembrar aos alunos que a PII indireta costuma ser o principal caminho para a desanonimização de dados.
-->

---

<!-- _class: lead -->

# Serviço de Desidentificação de PII

<!--
Goal: Transition to Segment 3
39:00 ~ 41:00 | 51:00
- Direcionar o foco para a implementação do desenvolvedor.
- Apresentar o Interceptor Pattern como o padrão de engenharia para aplicar a Regra de Ouro.
-->

---

## 🛡️ O que é o Presidio?

<!-- _footer: "[Fonte: GitHub](https://github.com/microsoft/presidio)" -->

- **Microsoft Presidio**: Combina motores de NLP (spaCy/Transformers) com regex
- **100% Local e Privado**: Zero chamadas de APIs externas.
- **Dados Não Estruturados**: Identificanomes, emails, CPFs e credenciais

![center](./anonymizer-design.png)

<!--
Goal: Define the Interceptor pattern and Microsoft Presidio
41:00 ~ 46:00 | 49:00
- Explicar o conceito geral do middleware Interceptor.
- Enfatizar que a LLM é mantida completamente cega a detalhes privados dos usuários.
-->

---

## Executando Localmente

- **O que é NLP?**: Modelos matemáticos treinados para transformar texto não estruturado em números (vetores) para extrair contexto, gramática e sintaxe.
- **Reconhecimento de Entidade Nomeada (NER)**: Subtarefa de NLP que varre o texto e rotula palavras como `PERSON`, `LOCATION`, `DATE`, etc.
- **Requisitos para Executar Localmente**:
  - **Python NLP**: `spaCy` ou `NLTK`
  - **Modelo Pré-treinado**: `pt_core_news_sm` (~13MB).
  - **Hardware**: Sem necessidade de GPU. CPU padrão de servidor e RAM mínima são suficientes.

<!--
Goal: Explain NLP at a high level and local resource requirements
46:00 ~ 50:00 | 44:00
- Desmistificar o Processamento de Linguagem Natural (NLP) e o Reconhecimento de Entidade Nomeada (NER) como pura projeção matemática (vetores).
- Enfatizar que executar Presidio e spaCy localmente não requer hardware de GPU pesado e consome pouquíssima memória.
-->

---

## Executando NLP Localmente

```bash
git clone https://github.com/roriz/mba-on-rails

cd mba-on-rails

./2-poisoning/presidio_demo/irb_session.rb
```

*Veja o Presidio identificar e anonimizar nomes, emails e telefones localmente em uma sessão simples de IRB.*

<!--
Goal: Run the local Presidio demo
50:00 ~ 55:00 | 40:00
- Instruir os alunos a executarem o script IRB local para ver o Presidio em ação.
- Demonstrar que a detecção funciona 100% de forma local e instantânea.
-->

---

## Tokenização Reversível

- **Redação Ingênua quebra o contexto da LLM**:
  - *"[PERSON] met [PERSON], and she gave him a book."* (A LLM perde a noção de quem é quem).
- **A Solução: Pseudonimização Reversível**:
  - Substituir PII por placeholders indexados e rastreáveis: `[PERSON_1]`, `[PERSON_2]`.
- **O Ciclo de Vida do Interceptor**:
  1. **Interceptar**: O middleware Rails intercepta o prompt original.
  2. **Anonimizar**: Detecta PII e substitui por placeholders (ex: `Alice` → `[PERSON_1]`).
  3. **Mapear & Consultar**: Salva o mapa de tradução em memória e envia o prompt anonimizado à LLM externa.
  4. **Reidratar**: Substitui os placeholders na resposta da LLM pelos dados reais antes de retornar ao usuário.

<!--
Goal: Explain Reversible Pseudonymization (Interception and Re-hydration)
55:00 ~ 60:00 | 35:00
- Explicar por que a redação comum (apenas deletar nomes) arruína o raciocínio relacional da LLM.
- Definir pseudonimização usando marcadores indexados ([PERSON_1]).
- Detalhar o ciclo de vida simplificado de 4 etapas de Interceptação e Reidratação.
-->

---

<!-- _class: lead -->

# Viés

---

## Loss Landscapes Multidimensionais

<div class="split-50">

<div>

- **A Geometria do Treinamento**: Cada LLM mapeia os dados para uma superfície matemática única (**Loss Landscape**) com base em seus pesos e arquitetura.
- **Caminhos Únicos de Otimização**: Por definição do treinamento, os modelos convergem para mínimos locais (vales) totalmente distintos.
- **Não é um Problema de Prompt ou Testes**: O viés não é um bug superficial de prompt está gravado na geometria estrutural do modelo.

</div>

<div>

![](./loss-landscaping.jpg)

</div>

</div>

<!--
Goal: Explain High-Dimensional Loss Landscapes & Training Geometry
60:00 ~ 65:00 | 30:00
- Destacar que o treinamento de cada modelo molda uma paisagem matemática totalmente única.
- Enfatizar que os modelos escolhem caminhos de otimização fundamentalmente diferentes por design.
-->

---

## Dados Diferentes, Respostas Diferentes

<div class="split-70-30">

<div>

- **Preferências de Palavras Intrínsecas**: O loss landscape cria vetores matemáticos fortes em direção a sentimentos específicos.
- **Viés de Cultura e Dados de Origem**:
  - **Modelo treinado nos EUA**: Ao descrever o *Governo Chinês*, caminha automaticamente para palavras como *autoritário* ou *vigilância*.
  - **Modelo treinado na China**: Sob o exato mesmo prompt, converge para *infraestrutura*, *harmonioso* ou *estabilidade*.
- **A Lição**: A geopolítica é apenas um exemplo extremo esta divergência estrutural aplica-se a todos os temas sensíveis (ex: *aborto, crimes, ética, preconceitos*). Modelos **nunca serão iguais**.

</div>

<div>

![](./America-and-china.jpeg)

</div>

</div>

<!--
Goal: Demonstrate intrinsic cultural/geopolitical bias in models
65:00 ~ 70:00 | 25:00
- Explicar como diferentes datasets de treinamento enviesam os vetores e a escolha de adjetivos.
- Usar o exemplo dos modelos EUA vs China para mostrar que a escolha das palavras está impregnada no loss landscape do modelo.
-->

---

## Por que a Remoção Simples Falha

<div class="split-50">

<div>

- Remover uma palavra (PII) **não achata o vale**.
- **Reidratação de Contexto**: O gradiente matemático continua fluindo na direção do mesmo vale tendencioso.
- **Coordenadas de Proxy**: O contexto ao redor (**as variáveis proxy**) continua mapeando exatamente para as mesmas coordenadas no espaço vetorial.

</div>

<div>

![](./loss-models.jpg)

</div>

</div>

<!--
Goal: Demonstrate why simple redaction fails mathematically
70:00 ~ 75:00 | 20:00
- Explicar como os mecanismos de atenção reconstroem dados faltantes (imputação).
- Mostrar que, como as variáveis proxy possuem coordenadas similares, remover um único token não muda a direção do vetor.
-->

---

## Diversidade como Superpoder

<!-- _footer: "[Fonte: @AkitaOnRails no X](https://x.com/AkitaOnRails/status/2058743721210827042)" -->

<div class="split-70-30">

<div>

- **Diferenças não são um bug**:
  - Podemos alavancar as variações de landscape para capturar problemas críticos.
- **Akita**:
  - Executou a mesma funcionalidade de software em todas as principais LLMs em paralelo.
  - **O Resultado**: Cada modelo detectou falhas e cenários de borda completamente diferentes que passariam despercebidos em uma única LLM.

</div>

<div>

![](./akita.jpg)

</div>

</div>

<!--
Goal: Transition landscape differences into the Jury Council solution
75:00 ~ 79:00 | 15:00
- Mostrar que a diversidade em loss landscapes é um poderoso ativo de engenharia.
- Compartilhar o exemplo real do Akita de avaliação multimodelos capturando bugs diversos no código.
- Estabelecer a importância do consenso multimodelo para abrir caminho ao ActiveGenie.
-->

---

## O que é o ActiveGenie?

<div class="split-70-30">

<div>

- **O "Lodash" para GenAI**: Uma biblioteca Ruby consistente e independente de modelo para orquestrar funcionalidades confiáveis de LLM em aplicações Rails.
- **Três Pilares Centrais**:
  - **Benchmarking Personalizado**: Garante testes determinísticos contra atualizações de modelos.
  - **Prontidão de Raciocínio**: Automatiza padrões cognitivos avançados como debate de múltiplas personas.
  - **Ajuste Fino de Prompts**: Modelos especializados, construídos sob medida, para alta estabilidade.

</div>

<div>

![](./active_genie.jpg)

</div>

</div>

<!--
Goal: Introduce ActiveGenie
79:00 ~ 82:00 | 11:00
- Definir o ActiveGenie como um framework fundamental para estruturar fluxos de trabalho de LLMs.
- Detalhar os três pilares, explicando como a GenAI estruturada vai além de simples prompts.
-->

---

## Como o JuryBench Funciona

A classe `ActiveGenie::Scorer::JuryBench` orquestra o padrão de múltiplos especialistas "Jury Council" internamente:

1. **Recomendação de Júri**: Aciona `Lister::Juries` para sugerir perfis especialistas baseados no conteúdo caso nenhum seja definido.
2. **Geração de Schema Dinâmico**: Cria um schema dinâmico de JSON Function Calling forçando a LLM a extrair de cada jurado:
   - `"<nome_jurado>_reasoning"` (obriga o modelo a justificar seu ponto de vista).
   - `"<nome_jurado>_score"` (obriga o modelo a atribuir uma nota de 0 a 100).
3. **Cálculo de Consenso**: Consolida a extração em parâmetros finais de `final_score` e `final_reasoning` no próprio schema.

<!--
Goal: Explain the inner mechanics of JuryBench
82:00 ~ 85:00 | 08:00
- Aprofundar no design de código do JuryBench.
- Explicar como a geração dinâmica de esquemas JSON força o modelo a registrar raciocínio e pontuação para cada especialista antes de calcular o consenso.
- Mostrar como isso mitiga a variabilidade da linguagem natural e o viés de temperatura.
-->

---

## Demo do ActiveGenie

```bash
git clone https://github.com/roriz/mba-on-rails

cd mba-on-rails

./2-poisoning/presidio_demo/irb_session.rb
```

*Veja a pontuação de consenso consolidar saídas altamente estáveis entre múltiplas execuções.*

<!--
Goal: Present the second demo
85:00 ~ 87:00 | 05:00
- Executar a demonstração do conselho ActiveGenie.
- Mostrar como modelos individuais divergem, mas o resultado final do conselho consolidado permanece altamente estável.
-->

---

<!-- _class: lead -->

# A Regra de Ouro
## "Nunca envie dados brutos de usuários para um provedor externo de LLM."

<!--
Goal: Establish the core architectural constraint
87:00 ~ 90:00 | 03:00
- Entregar a regra de ouro para a construção de pipelines de IA seguros.
- Enfatizar que o isolamento do lado do servidor é a nossa única garantia absoluta.
-->
