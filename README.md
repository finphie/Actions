# Actions

GitHub Actions関連ファイルの管理と、各種設定の同期を行っているリポジトリです。

## Composite actions

### check-extension

リポジトリ内に特定拡張子のファイルが含まれているか確認するGitHub Actionです。

```yml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Check extension
        id: check-extension
        uses: finphie/Actions/.github/actions/check-extension@main

      - run: |
          echo '${{ steps.check-extension.outputs.dotnet }}'
          echo '${{ steps.check-extension.outputs.powershell }}'
          echo '${{ steps.check-extension.outputs.python }}'
          echo '${{ steps.check-extension.outputs.html }}'
          echo '${{ steps.check-extension.outputs.javascript }}'
          echo '${{ steps.check-extension.outputs.typescript }}'
          echo '${{ steps.check-extension.outputs.json }}'
          echo '${{ steps.check-extension.outputs.yaml }}'
          echo '${{ steps.check-extension.outputs.markdown }}'
          echo '${{ steps.check-extension.outputs.docker }}'
```

#### 引数

なし

#### 環境変数

なし

#### 出力

名前|型|説明
-|-|-
dotnet|bool|.NETファイルが含まれているかどうか。
powershell|bool|PowerShellファイルが含まれているかどうか。
python|bool|Pythonファイルが含まれているかどうか。
html|bool|HTMLファイルが含まれているかどうか。
javascript|bool|JavaScriptファイルが含まれているかどうか。
typescript|bool|TypeScriptファイルが含まれているかどうか。
json|bool|JSONファイルが含まれているかどうか。
yaml|bool|YAMLファイルが含まれているかどうか。
markdown|bool|Markdownファイルが含まれているかどうか。
docker|bool|Dockerfileが含まれているかどうか。

### copy-github-labels

GitHubラベルをソース元のリポジトリからコピーするGitHub Actionです。

```yml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Copy GitHub labels
        uses: finphie/Actions/.github/actions/copy-github-labels@main
        with: 
          repositories: |
            finphie/dotfiles
          source-repository: finphie/Actions
        env:
          GITHUB_TOKEN: ${{ secrets.PAT }}
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
repositories|string[]|**true**|-|リポジトリのリスト。
source-repository|string|**true**|-|ソース元のリポジトリ。

#### 環境変数

名前|型|必須|デフォルト|説明
-|-|-|-|-
GITHUB_TOKEN|string|**true**|-|「public_repo」スコープを許可したGitHub Personal Access Token。

#### 出力

なし

### create-pull-request

プルリクエストを作成するGitHub Actionです。

```yml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Create pull request
        uses: finphie/Actions/.github/actions/create-pull-request@main
        with: 
          path: ${{ github.workspace }}
          commit-message: Commit message
          branch: create-pull-request
          labels: null
        env:
          GITHUB_TOKEN: ${{ secrets.PAT }}
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
path|string|false|github.workspace|リポジトリのパス。
commit-message|string|**true**|-|コミットメッセージ。
branch|string|false|create-pull-request|ブランチ名。
labels|string[]|false|null|ラベルのリスト。

#### 環境変数

名前|型|必須|デフォルト|説明
-|-|-|-|-
GITHUB_TOKEN|string|**true**|-|secrets.GITHUB_TOKENまたは「public_repo」スコープを許可したGitHub Personal Access Token。（他のリポジトリにPRを出す場合はPAT必須）

#### 出力

なし

### get-github-repositories

GitHubリポジトリ名を取得するGitHub Actionです。

```yml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Get GitHub repositories
        id: get-github-repositories
        uses: finphie/Actions/.github/actions/get-github-repositories@main
        with: 
          archived: false
          fork: false
          language: null
          limit: false
          no-archived: false
          source: false
          visibility: public
          exclude: null
        env:
          GITHUB_TOKEN: ${{ secrets.PAT }}

      - run: |
          echo '${{ steps.get-github-repositories.outputs.repositories }}'

```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
path|string|false|${{ github.workspace }}|リポジトリのパス。
commit-message|string|**true**|-|コミットメッセージ。
branch|string|false|create-pull-request|ブランチ名。
labels|string[]|false|null|ラベルのリスト。
archived|bool|false|false|アーカイブされたリポジトリを取得する。no-archivedと同時に有効にはできない。
fork|bool|false|false|フォークしたリポジトリを取得する。sourceと同時に有効にはできない。
language|string|false|null|指定された言語が主要なリポジトリを取得する。
limit|int|false|1000|取得するリポジトリの最大数。
no-archived|bool|false|false|アーカイブされていないリポジトリを取得する。archivedと同時に有効にはできない。
source|bool|false|false|フォークではないリポジトリを取得する。forkと同時に有効にはできない。
visibility|enum|false|public|指定された可視性（public/private/internal）のリポジトリを取得する。
exclude|string[]|false|null|除外する「オーナー名/リポジトリ名」形式のリスト。

#### 環境変数

名前|型|必須|デフォルト|説明
-|-|-|-|-
GITHUB_TOKEN|string|**true**|-|「public_repo」スコープを許可したGitHub Personal Access Token。

#### 出力

名前|型|説明
-|-|-
repositories|string[]|「オーナー名/リポジトリ名」のリスト。

### git-versioning

バージョン情報を取得するGitHub Actionです。

```yml
on:
  push:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Git versioning
        id: git-versioning
        uses: finphie/Actions/.github/actions/git-versioning@main
        with: 
          file-name: version.json
          hash: ${{ github.sha }}
          revision: ${{ github.run_number }}

      - run: |
          echo '${{ steps.git-versioning.outputs.version }}'
          echo '${{ steps.git-versioning.outputs.version-major }}'
          echo '${{ steps.git-versioning.outputs.version-minor }}'
          echo '${{ steps.git-versioning.outputs.version-build }}'
          echo '${{ steps.git-versioning.outputs.version-revision }}'
          echo '${{ steps.git-versioning.outputs.release }}'
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
file-name|string|false|version.json|バージョンを設定しているJSONファイルの名前。
hash|string|false|${{ github.sha }}|基点とするコミットハッシュ値。このハッシュ値以降のコミットで、JSONファイルが更新されている場合は安定版リリースとなり、リビジョン番号を省略したバージョン形式となる。
revision|int|false|${{ github.run_number }}|リビジョン番号。

#### 環境変数

なし

#### 出力

名前|型|説明
-|-|-
version|string|バージョン
version-major|string|メジャー番号
version-minor|string|マイナー番号
version-build|string|ビルド番号
version-revision|string|リビジョン番号
release|string|安定版リリースかどうか

### pascal-to-kebab

指定されたテキストを、PascalCaseからkebab-caseに変換するGitHub Actionです。

```yml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Pascal to kebab
        id: pascal-to-kebab
        uses: finphie/Actions/.github/actions/pascal-to-kebab@main
        with: 
          text: Text

      - run: |
          echo '${{ steps.pascal-to-kebab.outputs.text }}'
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
text|string|**true**|-|変換対象の文字列。

#### 環境変数

なし

#### 出力

名前|型|説明
-|-|-
text|string|変換後の文字列。

### sync-repositories

ソース元のリポジトリと同期するGitHub Actionです。

```yml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Sync repositories
        uses: finphie/Actions/.github/actions/sync-repositories@main
        with: 
          source-path:
          target-path:
          settings-file-path:
          commit-message: Commit message
          branch: sync-github-repositories
          labels: null
        env:
          GITHUB_TOKEN: ${{ secrets.PAT }}
 
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
text|string|**true**|-|変換対象の文字列。

#### 環境変数

名前|型|必須|デフォルト|説明
-|-|-|-|-
GITHUB_TOKEN|string|**true**|-|「public_repo」スコープを許可したGitHub Personal Access Token。

#### 出力

なし

## Reusable workflows

### build-dotnet.yml

### build-markdown.yml

### build-powershell.yml

### build-python.yml

### build-yaml.yml

### deploy-docker.yml

## Workflows

### sync-dotfiles.yml

### sync-github-settings.yml

### sync-labels.yml

### sync-secrets.yml
