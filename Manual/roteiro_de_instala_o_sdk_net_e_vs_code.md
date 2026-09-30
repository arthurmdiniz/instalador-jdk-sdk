# Roteiro de Instalação: SDK .NET e Visual Studio Code

**Disciplina:** Gestão da Qualidade de Software / Garantia da Qualidade de Software

**Autor/Professor:** [Daniel Henrique Matos de Paiva](https://github.com/danhpaiva)

**Instituição:** Ânima Educação

---

## 1. Software Development Kit (SDK .NET)

Para desenvolver na linguagem .NET, é necessário baixar o Software Development Kit (SDK). Ele apoiará vocês tanto no desenvolvimento de aplicações .NET em outras Unidades Curriculares (disciplinas), quanto para executar programas já criados em C#.

> O .NET é uma plataforma de desenvolvedor gratuita, multiplataforma e de software livre para criar muitos tipos de aplicativos.

### Download

* **Link (.NET 10):** [https://dotnet.microsoft.com/pt-br/download/dotnet/10.0](https://dotnet.microsoft.com/pt-br/download/dotnet/10.0)

* **Instaladores disponíveis (SDK 10.0.401):**
  * **Linux:** Instruções do gerenciador de pacotes ou binários (x64, Arm64, Arm32, Alpine).
  * **macOS:** Instaladores/Binários `x64` | `Arm64`.
  * **Windows:** Instaladores/Binários `x64` | `x86` | `Arm64` ou via `winget`.

---

### Instalação do SDK

A instalação do SDK é simples e padrão:
1. Execute o instalador baixado (`Microsoft .NET SDK 10.0.401 (x64) Installer`).
2. Avance pelas etapas ("Next" / "Próximo") até concluir a instalação.

---

### Verificação da Instalação

Após instalar o SDK, verifique se a instalação ocorreu com sucesso:

1. No Windows, acesse o menu **Iniciar**, digite `cmd` ou **Windows Terminal** e pressione **Enter**.
2. Digite o comando:
   ```bash
   dotnet --version
   ```
3. A tela deverá retornar a versão instalada (exemplo: `10.0.401`).

*Guia detalhado para Windows:* [https://learn.microsoft.com/pt-br/dotnet/core/install/windows](https://learn.microsoft.com/pt-br/dotnet/core/install/windows)

---

## 2. Visual Studio Code (VS Code)

O Visual Studio Code é a IDE utilizada para desenvolver com .NET (C#).

### Download

* **Link:** [https://code.visualstudio.com/download](https://code.visualstudio.com/download)
* Escolha a versão do seu sistema operacional e realize o download.

---

### Passo a Passo da Instalação

1. **Acordo de Licença:** Marque a opção `[x] Eu aceito o acordo` e clique em **Próximo**.
2. **Selecionar Tarefas Adicionais:**
   * `[ ]` Criar um atalho na área de trabalho *(opcional)*
   * `[x]` Adicione a ação "Abrir com Code" ao menu de contexto de arquivo do Windows Explorer
   * `[x]` Adicione a ação "Abrir com Code" ao menu de contexto de diretório do Windows Explorer
   * `[x]` Registre Code como um editor para tipos de arquivos suportados
   * `[x]` Adicione em PATH (disponível após reiniciar)
3. **Conclusão:** Clique em **Instalar** e aguarde o término do processo.

---

### Configuração do C# no VS Code

1. Abra o Visual Studio Code.
2. Acesse a aba de **Extensões** (`Ctrl+Shift+X`).
3. Pesquise e instale as seguintes extensões oficiais da Microsoft:
   * **C# Dev Kit:** Pacote oficial da Microsoft para suporte completo ao desenvolvimento C# ([Link Marketplace](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit)).
   * **C#:** Suporte básico de linguagem para C#.
   * *(Opcional)* **C# Extensions** (de JosKreativ).

Após esses passos, você já conseguirá criar arquivos `.cs` e executar seus programas.

---
