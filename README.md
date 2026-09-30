# Kit de Instalação — Java e C# com Visual Studio Code

*Windows 10 / 11 — 64 bits*

Instala **OpenJDK 25**, **SDK .NET 10**, **Visual Studio Code** e as extensões dos dois idiomas.
Os passos `01`, `02` e `03` **baixam os instaladores na primeira execução** e depois usam só os arquivos
locais em `Installers\` — a partir daí dá para trabalhar sem internet. As extensões vêm da loja oficial
do VS Code, então esses dois passos precisam de rede.

**Documentação original:** [Daniel Henrique Matos de Paiva](https://github.com/danhpaiva) ·
**Scripts de instalação:** Arthur Marques Diniz / Opencode

---

## Requisitos

- **Windows 10/11 64 bits** e **PowerShell 5.1** (já vem no Windows).
- **Executar como administrador.** A instalação é **por máquina** (em `C:\Program Files`), não por conta de usuário.
- **≈ 1 GB livres** e **≈ 616 MB de download** na primeira vez.

Os instaladores não ficam no repositório porque o GitHub recusa arquivos acima de 100 MB.
Quem já tiver os arquivos, ou estiver sem rede, pode colocá-los em `Installers\` antes de rodar.

---

## Como usar

1. Copie ou clone esta pasta para a máquina.
2. Clique com o botão direito em **`Instalador_Geral.bat`** → *Executar como administrador*.
3. Ao abrir, o menu mostra o que **já está instalado** e o que ainda será baixado:

```
 Situacao desta maquina
 ----------------------------------------------
 Java (OpenJDK)              [ OK ] OpenJDK 25.0.4.101
 SDK .NET 10                 [FALTA] SDK .NET 10 nao instalado
 VS Code                    [AVISO] instalado so por usuario; o passo 03 instala a system
 Ext. Java                   [FALTA] vscjava.vscode-java-pack
 Ext. C#                     [ OK ] 3 extensoes
 ----------------------------------------------
 Cache: 188,8 MB ja em Installers\.
 Baixar: 427,6 MB (SDK .NET 10, VS Code)
```

4. Escolha a opção e acompanhe. A opção **1** instala **só o que falta**; o que já existe vira `[SKIP]`,
   sem baixar e sem reinstalar.
5. Tudo fica registrado no `install-log.txt`, criado na raiz da pasta.

> **Sem internet?** Ponha os 3 instaladores em `Installers\` (os endereços estão em `links_de_download.txt`)
> e rode: os passos `01` a `03` passam a não usar a rede. **As extensões ainda exigem rede** — instale-as
> pelo VS Code (`Ctrl+Shift+X`) enquanto puder.

> **Prefere fazer na mão?** Os roteiros passo a passo estão em [`Manual/`](Manual/).

---

## Se algo der errado

O `install-log.txt` marca cada etapa como `[PASS]`, `[SKIP]` (já estava instalado — **não é erro**) ou `[FAIL]`.

| Mensagem | O que fazer |
|---|---|
| `ATENCAO: ... como ADMINISTRADOR` | Botão direito no `.bat` → *Executar como administrador* |
| `Falha no download: ...` | Confira a rede, ou baixe o instalador em outra máquina e coloque em `Installers\` |
| `Mais de um instalador ... encontrado` | Deixe **apenas um** arquivo de cada tipo na pasta |
| `'java'` / `'dotnet'` / `'code'` não é reconhecido | O PATH mudou, mas o terminal é antigo. Abra um **novo** terminal |
| `VS Code nao encontrado. Execute primeiro o passo 03` | Rode o `03` antes dos passos `04` e `05` |
| Extensão não instalou | `Ctrl+Shift+X` no VS Code e procure por "Extension Pack for Java" ou "C# Dev Kit" |

Depois de instalar, abra um terminal novo e confirme:

```bat
java -version
dotnet --version
code --version
```

---

## Créditos

- **Documentação original** — os roteiros de `Manual\`, baseados nas disciplinas *Gestão e Qualidade de
  Software* e *Garantia da Qualidade do Software*: **[Daniel Henrique Matos de Paiva](https://github.com/danhpaiva)** — Professor, *Ânima Educação*.
- **Scripts de instalação** — `Instalador_Geral.bat` e os `01` a `05_*.ps1`:
  **Arthur Marques Diniz** / Opencode.

Licença **MIT** — veja [`LICENSE`](LICENSE). Copyright (c) 2026 Arthur Marques Diniz.

> A documentação de cada ferramenta citada (OpenJDK, .NET SDK, Visual Studio Code, Extension Pack for
> Java e C# Dev Kit) pertence aos respectivos projetos, sob suas próprias licenças.