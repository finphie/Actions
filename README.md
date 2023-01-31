# Actions

[![Sync(dotfiles)](https://github.com/finphie/Actions/actions/workflows/sync-dotfiles.yml/badge.svg)](https://github.com/finphie/Actions/actions/workflows/sync-dotfiles.yml)
[![Sync(GitHub settings)](https://github.com/finphie/Actions/actions/workflows/sync-github-settings.yml/badge.svg)](https://github.com/finphie/Actions/actions/workflows/sync-github-settings.yml)
[![Sync(labels)](https://github.com/finphie/Actions/actions/workflows/sync-labels.yml/badge.svg)](https://github.com/finphie/Actions/actions/workflows/sync-labels.yml)
[![Sync(secrets)](https://github.com/finphie/Actions/actions/workflows/sync-secrets.yml/badge.svg)](https://github.com/finphie/Actions/actions/workflows/sync-secrets.yml)

GitHub Actions関連ファイルの管理と、各種設定の同期を行うリポジトリです。

## 目次

- [複合アクション](#複合アクション)
  - [check-extension](#check-extension)
  - [compress-archive](#compress-archive)
  - [copy-github-labels](#copy-github-labels)
  - [create-pull-request](#create-pull-request)
  - [get-github-repositories](#get-github-repositories)
  - [git-push](#git-push)
  - [git-versioning](#git-versioning)
  - [pascal-to-kebab](#pascal-to-kebab)
  - [read-file](#read-file)
  - [run-msbuild-target](#run-msbuild-target)
  - [sync-repositories](#sync-repositories)
  - [update-repository-json](#update-repository-json)
  - [upload-release-assets](#upload-release-assets)
- [再利用可能なワークフロー](#再利用可能なワークフロー)
  - [build-dotnet.yml](#build-dotnetyml)
  - [build-markdown.yml](#build-markdownyml)
  - [build-powershell.yml](#build-powershellyml)
  - [build-python.yml](#build-pythonyml)
  - [build-yaml.yml](#build-yamlyml)
  - [deploy-docker.yml](#deploy-dockeryml)
  - [deploy-dotnet.yml](#deploy-dotnetyml)
  - [get-version.yml](#get-versionyml)
  - [release.yml](#releaseyml)
  - [update-repository-json.yml](#update-repository-jsonyml)
- [ワークフロー](#ワークフロー)
  - [sync-dotfiles.yml](#sync-dotfilesyml)
  - [sync-github-settings.yml](#sync-github-settingsyml)
  - [sync-labels.yml](#sync-labelsyml)
  - [sync-secrets.yml](#sync-secretsyml)
- [作者](#作者)
- [ライセンス](#ライセンス)

## 複合アクション

### check-extension

リポジトリ内に特定拡張子のファイルが含まれているか確認するGitHub Actionです。

```yaml
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
        with:
          paths: |
            *
            Source/*
          recurse: false

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
          echo '${{ steps.check-extension.outputs.nuget }}'
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
paths|string[]|false|\*,Source/\*|検索するファイルパス（拡張子なし）のリスト。
recurse|bool|false|false|再帰検索するかどうか。

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
nuget|bool|NuGetパッケージファイルが含まれているかどうか。

### compress-archive

zipファイルを作成するGitHub Actionです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Compress archive
        uses: finphie/Actions/.github/actions/compress-archive@main
        with: 
          path: target-path
          destination-file-path: a.zip
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
path|string|**true**|-|圧縮対象のファイルが存在するディレクトリ。
destination-file-path|string|false|null|出力先ファイルパス。省略した場合は、path内のディレクトリ毎にzipファイルを作成する。
suffix|string|false|null|zipファイル名の末尾に追加する文字列。destination-file-pathを指定しない場合のみ有効。

#### 環境変数

なし

#### 出力

なし

### copy-github-labels

GitHubラベルをソース元のリポジトリからコピーするGitHub Actionです。

```yaml
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

#### 同一リポジトリにプルリクエストを出す場合

```yaml
on:
  push:
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        if: github.ref_name == 'main'
        uses: actions/checkout@v3
        with:
          ref: ${{ github.ref }}

      - name: Checkout repository
        if: github.ref_name != 'main'
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Create pull request
        uses: finphie/Actions/.github/actions/create-pull-request@main
        with: 
          path: ${{ github.workspace }}
          commit-message: Commit message
          branch: create-pull-request
          labels: null
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### 他のリポジトリにプルリクエストを出す場合

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          repository: finphie/dotfiles
          token: ${{ secrets.PAT }}

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
path|string|false|${{ github.workspace }}|リポジトリのパス。
commit-message|string|**true**|-|コミットメッセージ。
branch|string|false|create-pull-request|ブランチ名。
labels|string[]|false|null|ラベルのリスト。

#### 環境変数

名前|型|必須|デフォルト|説明
-|-|-|-|-
GITHUB_TOKEN|string|**true**|-|GITHUB_TOKENシークレットまたは「public_repo」スコープを許可したGitHub Personal Access Token。（他のリポジトリにPRを出す場合はPAT必須）

#### 出力

なし

### get-github-repositories

GitHubリポジトリ名を取得するGitHub Actionです。

```yaml
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

### git-push

Git pushを実行するGitHub Actionです。

```yaml
on:
  pull_request:

permissions:
  contents: write

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          ref: ${{ github.event.pull_request.head.ref }}

      - name: Git push
        uses: finphie/Actions/.github/actions/git-push@main
        with: 
          commit-message: Commit message
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
commit-message|string|**true**|-|コミットメッセージ。

#### 環境変数

なし

#### 出力

なし

### git-versioning

バージョン情報を取得するGitHub Actionです。

```yaml
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
revision|int|false|${{ github.run_number }}|リビジョン番号を表す数値。

#### 環境変数

なし

#### 出力

名前|型|説明
-|-|-
version|string|バージョンを表す文字列。
version-major|int|メジャー番号を表す数値。
version-minor|int|マイナー番号を表す数値。
version-build|int|ビルド番号を表す数値。
version-revision|int|リビジョン番号を表す数値。
release|bool|安定版リリースかどうか。

### pascal-to-kebab

指定されたテキストを、PascalCaseからkebab-caseに変換するGitHub Actionです。

```yaml
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

### read-file

テキストファイルを読み込むGitHub Actionです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Read file
        id: read-file
        uses: finphie/Actions/.github/actions/read-file@main
        with: 
          file-path: text.txt

      - run: |
          echo '${{ steps.read-file.outputs.text }}'
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
file-path|string|**true**|-|テキストファイルのパス。

#### 環境変数

なし

#### 出力

名前|型|説明
-|-|-
text|string|ファイル内容。

### run-msbuild-target

MSBuildターゲットを実行するGitHub Actionです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Run MSBuild target
        id: run-msbuild-target
        uses: finphie/Actions/.github/actions/run-msbuild-target@main
        with: 
          target: TargetName

      - run: |
          echo '${{ steps.run-msbuild-target.outputs.lines }}'
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
target|string|**true**|-|MSBuildターゲット名。

#### 環境変数

なし

#### 出力

名前|型|説明
-|-|-
lines|string[]|MSBuildターゲット実行時に出力された文字列。

### sync-repositories

ソース元のリポジトリと同期するGitHub Actionです。

```yaml
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
          source-path: source-repository
          target-path: target-repository
          settings-file-path: target-repository/dotfiles.json
          commit-message: Commit message
          branch: sync-github-repositories
          labels: null
        env:
          GITHUB_TOKEN: ${{ secrets.PAT }}
 
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
source-path|string|**true**|-|ソース元リポジトリのパス。
target-path|string|**true**|-|同期先リポジトリのパス。
settings-file-path|string|**true**|-|JSON設定ファイルのパス。このファイルの"hash"の値から前回同期位置を特定する。
commit-message|string|**true**|-|コミットメッセージ。
branch|string|false|sync-github-repositories|ブランチ名。
labels|string[]|false|chore|ラベルのリスト。

#### 環境変数

名前|型|必須|デフォルト|説明
-|-|-|-|-
GITHUB_TOKEN|string|**true**|-|「public_repo」スコープを許可したGitHub Personal Access Token。

#### 出力

なし

### update-repository-json

repository.jsonを更新するGitHub Actionです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      # 実行にはPowerShell 7.3以上が必要。
      - name: Update PowerShell
        working-directory: ${{ runner.temp }}
        run: |
          wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
          sudo dpkg -i packages-microsoft-prod.deb
          sudo apt-get install -y powershell

      - name: Update repository.json
        uses: finphie/Actions/.github/actions/update-repository-json@main
        with: 
          solution-name: ${{ github.event.repository.name }}
          projects: |
            Project1,Windows
            Project2,Console

      - run: cat repository.json
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
solution-name|string|false|-|ソリューション名。
projects|string|**true**|-|「プロジェクト名,プラットフォーム名」区切りのリスト。

#### 環境変数

なし

#### 出力

なし

### upload-release-assets

リリースにファイルをアップロードするGitHub Actionです。

```yaml
on:
  workflow_dispatch:

permissions:
  contents: write

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Upload release assets
        uses: finphie/Actions/.github/actions/upload-release-assets@main
        with: 
          tag: v1.0.0
          files: |
            *.zip
            *.exe
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
tag|string|**true**|-|対象のgitタグ。
files|string|**true**|-|アップロード対象のファイルリスト。

#### 環境変数

なし

#### 出力

なし

## 再利用可能なワークフロー

### build-dotnet.yml

.NETのビルドを実行する再利用可能なワークフローです。`dotnet build`と`dotnet test`を実行します。

```yaml
on:
  pull_request:

permissions: {}

jobs:
  main:
    uses: finphie/Actions/workflows/build-dotnet.yml@main
    with:
      dotnet-version: '7.0'
      configuration: Release
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
dotnet-version|string|false|7.0|インストールする.NET SDKバージョン。
configuration|string|false|Release|ビルド構成。

#### 環境変数

なし

#### 出力

なし

### build-markdown.yml

Markdownのビルドを実行する再利用可能なワークフローです。markdownlintを実行します。

```yaml
on:
  pull_request:

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/build-markdown.yml@main
```

#### 引数

なし

#### 環境変数

なし

#### 出力

なし

### build-powershell.yml

PowerShellのビルドを実行する再利用可能なワークフローです。PSScriptAnalyzerを実行します。

```yaml
on:
  pull_request:

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/build-powershell.yml@main
```

#### 引数

なし

#### 環境変数

なし

#### 出力

なし

### build-python.yml

Pythonのビルドを実行する再利用可能なワークフローです。flake8とpyrightを実行します。

```yaml
on:
  pull_request:

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/build-python.yml@main
```

#### 引数

なし

#### 環境変数

なし

#### 出力

なし

### build-yaml.yml

YAMLのビルドを実行する再利用可能なワークフローです。yamllintを実行します。

```yaml
on:
  pull_request:

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/build-yaml.yml@main
```

#### 引数

なし

#### 環境変数

なし

#### 出力

なし

### deploy-docker.yml

Dockerのデプロイを実行する再利用可能なワークフローです。

```yaml
on:
  push:
    branches:
      - main

permissions:
  packages: write

jobs:
  main:
    uses: finphie/Actions/.github/workflows/deploy-docker.yml@main
    with:
      version: '1.2.3'
      version-major: 1
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
version|string|**true**|-|バージョンを表す文字列。
version-major|int|**true**|-|メジャーバージョンを表す数値。

#### 環境変数

なし

#### 出力

なし

### deploy-dotnet.yml

.NETのデプロイを実行する再利用可能なワークフローです。

```yaml
on:
  push:
    branches:
      - main

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/deploy-dotnet.yml@main
    with:
      dotnet-version: '7.0'
      configuration: Release
      version: '1.2.3'
      release: true
    secrets:
      AZURE_ARTIFACT_PAT: ${{ secrets.AZURE_ARTIFACT_PAT }}
      NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
dotnet-version|string|false|7.0|インストールする.NET SDKバージョン。
configuration|string|false|Release|ビルド構成。
version|string|**true**|-|バージョンを表す文字列。
release|bool|**true**|-|安定版リリースかどうか。

#### 環境変数

なし

#### シークレット

名前|型|必須|デフォルト|説明
-|-|-|-|-
AZURE_ARTIFACT_PAT|string|**true**|-|「Packaging」スコープの読み書きを許可したAzure DevOps Personal Access Token。
NUGET_API_KEY|string|**true**|-|「Push」スコープを許可したNuGet APIキー。

#### 出力

なし

### get-version.yml

現在のバージョンを取得する再利用可能なワークフローです。

```yaml
on:
  push:
    branches:
      - main

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/get-version.yml@main

  echo:
    needs: main
    run: |
      echo '${{ needs.main.outputs.version }}'
      echo '${{ needs.main.outputs.version-major }}'
      echo '${{ needs.main.outputs.release }}'
      echo '${{ needs.main.outputs.dotnet }}'
      echo '${{ needs.main.outputs.docker }}'
```

#### 引数

なし

#### 環境変数

なし

#### 出力

名前|型|説明
-|-|-
version|string|バージョンを表す文字列。
version-major|int|メジャー番号を表す数値。
release|bool|安定版リリースかどうか。
dotnet|bool|.NETファイルが含まれているかどうか。
docker|bool|Dockerfileが含まれているかどうか。

### release.yml

GitHubリリースを作成する再利用可能なワークフローです。

```yaml
on:
  push:
    branches:
      - main

permissions:
  contents: write

jobs:
  main:
    uses: finphie/Actions/.github/workflows/release.yml@main
    with:
      version: '1.0.0'
```

#### 引数

名前|型|必須|デフォルト|説明
-|-|-|-|-
version|string|**true**|-|バージョンを表す文字列。

#### 環境変数

なし

#### 出力

なし

### update-repository-json.yml

repository.jsonを更新する再利用可能なワークフローです。

```yaml
on:
  pull_request:

permissions:
  contents: write

jobs:
  main:
    uses: finphie/Actions/.github/workflows/update-repository-json.yml@main
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### 引数

なし

#### 環境変数

なし

#### 出力

なし

## ワークフロー

### sync-dotfiles.yml

各リポジトリに[finphie/dotfiles](https://github.com/finphie/dotfiles)のファイルを同期するワークフローです。

### sync-github-settings.yml

各リポジトリのGitHubの設定を行うワークフローです。[GitHubSettingsSync](https://github.com/finphie/GitHubSettingsSync)を使用します。

### sync-labels.yml

各リポジトリのラベルを同期するワークフローです。

### sync-secrets.yml

各リポジトリのシークレットを同期するワークフローです。

## 作者

finphie

## ライセンス

CC0 1.0
