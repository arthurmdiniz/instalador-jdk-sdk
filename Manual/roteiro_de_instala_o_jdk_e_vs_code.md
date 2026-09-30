# Roteiro de Instalação: OpenJDK e Visual Studio Code

**Disciplina:** Garantia da Qualidade de Software / Gestão e Qualidade de Software  
**Autor/Professor:** [Daniel Henrique Matos de Paiva](https://github.com/danhpaiva)  
**Instituição:** Ânima Educação  

---

## 1. Java Development Kit (JDK)

Para desenvolver na linguagem Java, é necessário baixar o Java Development Kit (JDK). Ele apoiará vocês tanto no desenvolvimento de aplicações Java em outras Unidades Curriculares, quanto para executar programas já criados em Java.

### Downloads

* **Sistemas Operacionais X64:**
  * **Link:** [https://learn.microsoft.com/pt-br/java/openjdk/download](https://learn.microsoft.com/pt-br/java/openjdk/download)
  * **Opções de Download disponíveis (OpenJDK 25 LTS):**
    * *Linux (x64):* `tar.gz` (`microsoft-jdk-25.0.4.1-linux-x64.tar.gz`)
    * *macOS (x64):* `pkg` (`microsoft-jdk-25.0.4.1-macos-x64.pkg`) ou `tar.gz`
    * *Windows (x64):* `exe`, `msi` (`microsoft-jdk-25.0.4.1-windows-x64.msi`) ou `zip`

* **Sistemas Operacionais X86 (32 bits):**
  * **Link 1 (Adoptium):** [https://adoptium.net/pt-BR/temurin/releases?version=8](https://adoptium.net/pt-BR/temurin/releases?version=8)
    * *Temurin jdk8u472-b08:* Windows x32 (ZIP 107 MB ou MSI 89 MB)
  * **Link 2 (Red Hat):** [https://developers.redhat.com/products/openjdk/download](https://developers.redhat.com/products/openjdk/download)
    * *OpenJDK 8 Windows 32-bit:* `jdk-8u362-x86 MSI` (105.37 MB)
    * *JRE 8 Windows 32-bit:* `jre-8u362-x86 ZIP` (43.03 MB)

> **O que é o OpenJDK?**  
> O OpenJDK é uma implementação livre e gratuita da plataforma Java, Edição Standard. É o resultado dos esforços da Comunidade Java para a evolução atemporal da linguagem. Serve como incubadora de novas ideias que normalmente são implementadas no JDK comercial da Oracle para serem rentabilizadas posteriormente.

---

### Instalação do OpenJDK

A instalação do OpenJDK é simples e comum: "next", "next", até finalizar.

**Atenção durante o assistente de instalação (Select Additional Tasks):**
Certifique-se de marcar as opções para configurar as variáveis de ambiente:
* `[x]` **Modify PATH variable:** Modify PATH environment variable by prepending the JDK installation directory to the beginning.
* `[x]` **Associate .jar:** Associate Microsoft Build of OpenJDK with the .jar file extension.
* `[x]` **Set or override JAVA_HOME:** Set or override JAVA_HOME environment variable with the JDK installation directory.
* `[ ]` **JavaSoft (Oracle) registry keys:** Overwrites Oracle registry key.

---

### Verificação da Instalação

Após instalarem o OpenJDK, verifiquem se a instalação ocorreu com sucesso:

1. No Windows, vá no menu Iniciar, digite `cmd` ou **Windows Terminal** e aperte **Enter**.
2. Digite o seguinte comando:
   ```bash
   java -version
   ```
3. A tela deverá retornar informações semelhantes a estas:
   ```text
   openjdk 25.0.4.1 2026-08-18 LTS
   OpenJDK Runtime Environment Microsoft-14951867 (build 25.0.4.1+1-LTS)
   OpenJDK 64-Bit Server VM Microsoft-14951867 (build 25.0.4.1+1-LTS, mixed mode, sharing)
   ```

*Nota: Para máquinas Linux, siga este tutorial:* [https://phoenixnap.com/kb/check-java-version-linux](https://phoenixnap.com/kb/check-java-version-linux)

---

## 2. Visual Studio Code (VS Code)

O Visual Studio Code é a IDE que utilizaremos para desenvolver utilizando a linguagem Java.

### Download
* **Link:** [https://code.visualstudio.com/download](https://code.visualstudio.com/download)
* Escolha a versão correspondente ao seu sistema operacional e realize o download.

---

### Passo a Passo da Instalação

1. **Acordo de Licença:** Aceite os termos ("Eu aceito o acordo") e clique em **Próximo**.
2. **Selecionar Tarefas Adicionais:**
   * Marcações recomendadas:
     * `[ ]` Criar um atalho na área de trabalho *(opcional)*
     * `[x]` Adicione a ação "Abrir com Code" ao menu de contexto de arquivo do Windows Explorer
     * `[x]` Adicione a ação "Abrir com Code" ao menu de contexto de diretório do Windows Explorer
     * `[x]` Registre Code como um editor para tipos de arquivos suportados
     * `[x]` Adicione em PATH (disponível após reiniciar)
3. **Pronto para Instalar:** Clique em **Instalar** e aguarde a conclusão.

---

### Configuração do Java no VS Code

1. Abra o Visual Studio Code.
2. Acesse o menu de **Extensões** (ícone de blocos na barra lateral esquerda ou `Ctrl+Shift+X`).
3. Procure e instale a extensão:
   * **Nome:** `Extension Pack for Java`
   * **Desenvolvedor:** Microsoft
   * **Descrição:** Popular extensions for Java development that provides Java IntelliSense, debugging, testing, Maven/Gradle support, project management and more.

Após esses passos, você já conseguirá criar uma classe no formato `.java` e executar o seu programa.

---