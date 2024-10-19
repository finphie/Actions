# Actions

[![Sync(dotfiles)](https://github.com/finphie/Actions/actions/workflows/sync-dotfiles.yml/badge.svg)](https://github.com/finphie/Actions/actions/workflows/sync-dotfiles.yml)
[![Sync(GitHub settings)](https://github.com/finphie/Actions/actions/workflows/sync-github-settings.yml/badge.svg)](https://github.com/finphie/Actions/actions/workflows/sync-github-settings.yml)
[![Sync(labels)](https://github.com/finphie/Actions/actions/workflows/sync-labels.yml/badge.svg)](https://github.com/finphie/Actions/actions/workflows/sync-labels.yml)
[![Sync(secrets)](https://github.com/finphie/Actions/actions/workflows/sync-secrets.yml/badge.svg)](https://github.com/finphie/Actions/actions/workflows/sync-secrets.yml)

GitHub Actions関連ファイルの管理と、各種設定の同期を行うリポジトリです。

## 目次

- 複合アクション
  - [check-extension](#check-extension)
  - [compress-archive](#compress-archive)
  - [copy-github-labels](#copy-github-labels)
  - [create-pull-request](#create-pull-request)
  - [dotnet-pack](#dotnet-pack)
  - [dotnet-publish](#dotnet-publish)
  - [get-dotnet-projects](#get-dotnet-projects)
  - [get-github-repositories](#get-github-repositories)
  - [git-push](#git-push)
  - [git-versioning](#git-versioning)
  - [pascal-to-kebab](#pascal-to-kebab)
  - [read-file](#read-file)
  - [run-msbuild-target](#run-msbuild-target)
  - [sync-repositories](#sync-repositories)
  - [upload-release-assets](#upload-release-assets)
- 再利用可能なワークフロー
  - [build-dotnet.yml](#build-dotnetyml)
  - [build-markdown.yml](#build-markdownyml)
  - [build-powershell.yml](#build-powershellyml)
  - [build-python.yml](#build-pythonyml)
  - [build-yaml.yml](#build-yamlyml)
  - [check-dotnet-platform.yml](#check-dotnet-platformyml)
  - [deploy-docker.yml](#deploy-dockeryml)
  - [deploy-dotnet.yml](#deploy-dotnetyml)
  - [get-version.yml](#get-versionyml)
  - [release.yml](#releaseyml)
  - [upload-artifacts-dotnet.yml](#upload-artifacts-dotnetyml)
  - [upload-nuget-library.yml](#upload-nuget-libraryyml)
- ワークフロー
  - [sync-dotfiles.yml](#sync-dotfilesyml)
  - [sync-github-settings.yml](#sync-github-settingsyml)
  - [sync-labels.yml](#sync-labelsyml)
  - [sync-secrets.yml](#sync-secretsyml)

## 複合アクション

### check-extension

リポジトリ内に特定拡張子のファイルが含まれているか確認するアクションです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Check extension
        id: check-extension
        uses: finphie/Actions/.github/actions/check-extension@main
        with:
          path: ${{ github.workspace }}
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
          echo '${{ steps.check-extension.outputs.zip }}'
          echo '${{ steps.check-extension.outputs.exe }}'
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
path|false|${{ github.workspace }}|検索対象のディレクトリ。
recurse|false|false|再帰検索するかどうか。

#### 環境変数

なし

#### 出力

名前|説明
-|-
dotnet|.NETファイルが含まれているかどうか。
powershell|PowerShellファイルが含まれているかどうか。
python|Pythonファイルが含まれているかどうか。
html|HTMLファイルが含まれているかどうか。
javascript|JavaScriptファイルが含まれているかどうか。
typescript|TypeScriptファイルが含まれているかどうか。
json|JSONファイルが含まれているかどうか。
yaml|YAMLファイルが含まれているかどうか。
markdown|Markdownファイルが含まれているかどうか。
docker|Dockerfileが含まれているかどうか。
nuget|NuGetパッケージファイルが含まれているかどうか。
zip|zipファイルが含まれているかどうか。
exe|exeファイルが含まれているかどうか。

### compress-archive

圧縮されたアーカイブを作成するアクションです。

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
          destination-path: a.zip
          root: true

      - name: Compress archive
        uses: finphie/Actions/.github/actions/compress-archive@main
        with: 
          path: target-path
          type: zip
          destination-path: destination-directory
          root: false
          suffix: _suffix
          exclude: |
            *.exe
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
path|**true**|-|圧縮対象のファイルが存在するディレクトリ。
type|false|zip|圧縮形式。zip/gzipのいずれか。
destination-path|false||rootがtrueの場合は、出力先ファイルパス。falseの場合は、出力先ディレクトリ。
root|false|true|path内のディレクトリ毎にzipファイルを作成するかどうか。
suffix|false||zipファイル名の末尾に追加する文字列。rootがfalseの場合のみ有効。
exclude|false||ディレクトリ内のファイルが1個の場合、圧縮対象とせずコピーを行うファイルのリスト。rootがfalseの場合のみ有効。

#### 環境変数

なし

#### 出力

なし

### copy-github-labels

GitHubラベルをソース元のリポジトリからコピーするアクションです。

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

名前|必須|デフォルト|説明
-|-|-|-
repositories|**true**|-|リポジトリのリスト。
source-repository|**true**|-|ソース元のリポジトリ。

#### 環境変数

名前|必須|デフォルト|説明
-|-|-|-
GITHUB_TOKEN|**true**|-|「public_repo」スコープを許可したGitHub Personal Access Token。

#### 出力

なし

### create-pull-request

プルリクエストを作成するアクションです。

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
        uses: actions/checkout@v4
        with:
          ref: ${{ github.ref }}

      - name: Checkout repository
        if: github.ref_name != 'main'
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Create pull request
        uses: finphie/Actions/.github/actions/create-pull-request@main
        with: 
          path: ${{ github.workspace }}
          commit-message: Commit message
          branch: create-pull-request
          labels: test
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
        uses: actions/checkout@v4
        with:
          repository: finphie/dotfiles
          token: ${{ secrets.PAT }}

      - name: Create pull request
        uses: finphie/Actions/.github/actions/create-pull-request@main
        with: 
          path: ${{ github.workspace }}
          commit-message: Commit message
          branch: create-pull-request
          labels: test
        env:
          GITHUB_TOKEN: ${{ secrets.PAT }}
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
path|false|${{ github.workspace }}|リポジトリのパス。
commit-message|**true**|-|コミットメッセージ。
branch|false|create-pull-request|ブランチ名。
labels|false||ラベルのリスト。

#### 環境変数

名前|必須|デフォルト|説明
-|-|-|-
GITHUB_TOKEN|**true**|-|GITHUB_TOKENシークレットまたは「public_repo」スコープを許可したGitHub Personal Access Token。（他のリポジトリにPRを出す場合はPAT必須）

#### 出力

なし

### dotnet-pack

dotnet packコマンドを実行するアクションです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: windows-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: .NET Pack
        uses: finphie/Actions/.github/actions/dotnet-pack@main
        with: 
          dotnet-version: 9.0.100-rc.2.24474.11
          configuration: Release
          version: '1.0.0'
          output-directory: pack
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
dotnet-version|false|9.0.100-rc.2.24474.11|インストールする.NET SDKバージョン。
configuration|false|Release|ビルド構成。
version|**true**|-|バージョンを表す文字列。
output-directory|false|pack|出力先ディレクトリ。

#### 環境変数

なし

#### 出力

名前|説明
-|-
success|nupkgファイルの生成に成功したかどうか。

### dotnet-publish

dotnet publishコマンドを実行するアクションです。`Source/${{ project }}/${{ project }}.csproj`を前提とします。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: windows-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: .NET Publish
        uses: finphie/Actions/.github/actions/dotnet-publish@main
        with: 
          dotnet-version: 9.0.100-rc.2.24474.11
          project: ProjectName
          configuration: Release
          version: '1.0.0'
          target-framework-moniker: net9.0
          target-platform-identifier: none
          target-platform-version: ''
          runtime: win-x64
          workload-restore: false
          output-directory: publish
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
dotnet-version|false|9.0.100-rc.2.24474.11|インストールする.NET SDKバージョン。
project|**true**|-|プロジェクト名。
configuration|false|Release|ビルド構成。
version|**true**|-|バージョンを表す文字列。
target-framework-moniker|false|net9.0|ターゲットフレームワーク。net9.0/net8.0/net7.0/net6.0のいずれか。
target-platform-identifier|false|none|プラットフォーム識別子。none/windows/android/maccatalyst/ios/tvos/tizenのいずれか。
target-platform-version|false||プラットフォームバージョンを表す文字列。
runtime|**true**|-|ランタイム識別子。
workload-restore|false|false|dotnet workload restoreを実行するかどうか。
output-directory|false|publish|出力先ディレクトリ。

#### 環境変数

なし

#### 出力

なし

### get-dotnet-projects

.NETプロジェクトの情報を取得するアクションです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Get .NET projects
        id: get-dotnet-projects
        uses: finphie/Actions/.github/actions/get-dotnet-projects@main
        with: 
          solution-name: ${{ github.event.repository.name }}
          projects: |
            Project1,Console
            Project2,Windows
            Project3,Android
            Project4,Server
            Project5,Browser
          settings-file-path: default.json

      - run: |
          echo '${{ steps.get-dotnet-projects.outputs.projects }}'
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
solution-name|false|-|ソリューション名。
projects|**true**|-|「プロジェクト名,プラットフォーム名」区切りのリスト。
settings-file-path|false|[default.json](.github/actions/get-dotnet-projects/default.json)|設定ファイルのパス。

#### 環境変数

なし

#### 出力

名前|説明
-|-
projects|[upload-artifacts-dotnet.yml](.github/workflows/upload-artifacts-dotnet.yml)ワークフローの引数となるJSON文字列を出力する。

### get-github-repositories

GitHubリポジトリ名を取得するアクションです。

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
          language: ''
          no-archived: false
          source: false
          visibility: public
          exclude: ''
          json: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - run: |
          echo '${{ steps.get-github-repositories.outputs.repositories }}'
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
source|false|false|フォークではないリポジトリを取得する。forkと同時に有効にはできない。
fork|false|false|フォークしたリポジトリを取得する。sourceと同時に有効にはできない。
archived|false|false|アーカイブされたリポジトリを取得する。no-archivedと同時に有効にはできない。
no-archived|false|false|アーカイブされていないリポジトリを取得する。archivedと同時に有効にはできない。
language|false||指定された言語が主要なリポジトリを取得する。
visibility|false|public|指定された可視性（public/private/internal）のリポジトリを取得する。
exclude|false||除外する「オーナー名/リポジトリ名」形式のリスト。
json|false|false|JSON形式で出力するかどうか。

#### 環境変数

名前|必須|デフォルト|説明
-|-|-|-
GITHUB_TOKEN|**true**|-|GITHUB_TOKENシークレット。

#### 出力

名前|説明
-|-
repositories|「オーナー名/リポジトリ名」のリスト。

### git-push

Git pushを実行するアクションです。

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
        uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.ref }}

      - name: Git push
        uses: finphie/Actions/.github/actions/git-push@main
        with: 
          commit-message: Commit message
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
commit-message|**true**|-|コミットメッセージ。

#### 環境変数

なし

#### 出力

なし

### git-versioning

バージョン情報を取得するアクションです。

```yaml
on:
  push:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

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

名前|必須|デフォルト|説明
-|-|-|-
file-name|false|version.json|バージョンを設定しているJSONファイルの名前。
hash|false|${{ github.sha }}|基点とするコミットハッシュ値。このハッシュ値以降のコミットで、JSONファイルが更新されている場合は安定版リリースとなり、リビジョン番号を省略したバージョン形式となる。
revision|false|${{ github.run_number }}|リビジョン番号を表す数値。

#### 環境変数

なし

#### 出力

名前|説明
-|-
version|バージョンを表す文字列。
version-major|メジャー番号を表す数値。
version-minor|マイナー番号を表す数値。
version-build|ビルド番号を表す数値。
version-revision|リビジョン番号を表す数値。
release|安定版リリースかどうか。

### pascal-to-kebab

指定されたテキストを、PascalCaseからkebab-caseに変換するアクションです。

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

名前|必須|デフォルト|説明
-|-|-|-
text|**true**|-|変換対象の文字列。

#### 環境変数

なし

#### 出力

名前|説明
-|-
text|変換後の文字列。

### read-file

テキストファイルを読み込むアクションです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Read file
        id: read-file
        uses: finphie/Actions/.github/actions/read-file@main
        with: 
          file-path: text.txt

      - run: |
          echo '${{ steps.read-file.outputs.text }}'
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
file-path|**true**|-|テキストファイルのパス。

#### 環境変数

なし

#### 出力

名前|説明
-|-
text|ファイル内容。

### run-msbuild-target

MSBuildターゲットを実行するアクションです。

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

名前|必須|デフォルト|説明
-|-|-|-
target|**true**|-|MSBuildターゲット名。

#### 環境変数

なし

#### 出力

名前|説明
-|-
lines|MSBuildターゲット実行時に出力された文字列。

### sync-repositories

ソース元のリポジトリと同期するアクションです。

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
          labels: sync
        env:
          GITHUB_TOKEN: ${{ secrets.PAT }}
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
source-path|**true**|-|ソース元リポジトリのパス。
target-path|**true**|-|同期先リポジトリのパス。
settings-file-path|**true**|-|JSON設定ファイルのパス。このファイルの"hash"の値から前回同期位置を特定する。
commit-message|**true**|-|コミットメッセージ。
branch|false|sync-github-repositories|ブランチ名。
labels|false|chore|ラベルのリスト。

#### 環境変数

名前|必須|デフォルト|説明
-|-|-|-
GITHUB_TOKEN|**true**|-|「public_repo」スコープを許可したGitHub Personal Access Token。

#### 出力

なし

### upload-release-assets

リリースにファイルをアップロードするアクションです。

```yaml
on:
  workflow_dispatch:

permissions:
  contents: write

jobs:
  main:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Upload release assets
        uses: finphie/Actions/.github/actions/upload-release-assets@main
        with: 
          tag: v1.0.0
          files: |
            **/*.zip
            **/*.exe
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
tag|**true**|-|対象のgitタグ。
files|**true**|-|アップロード対象のファイルリスト。

#### 環境変数

名前|必須|デフォルト|説明
-|-|-|-
GITHUB_TOKEN|**true**|-|GITHUB_TOKENシークレット。

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
      dotnet-version: 9.0.100-rc.2.24474.11
      configuration: Release
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
dotnet-version|false|9.0.100-rc.2.24474.11|インストールする.NET SDKバージョン。
configuration|false|Release|ビルド構成。

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

### check-dotnet-platform.yml

.NETプロジェクトのターゲットプラットフォーム名を取得する再利用可能なワークフローです。

```yaml
on:
  workflow_dispatch:

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/check-dotnet-platform.yml@main
    with:
      settings-file-path: default.json

  echo:
    needs: main
    run: |
      echo '${{ needs.main.outputs.projects }}'
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
settings-file-path|false|[default.json](.github/actions/get-dotnet-projects/default.json)|設定ファイルのパス。

#### 環境変数

なし

#### 出力

名前|説明
-|-
projects|[upload-artifacts-dotnet.yml](.github/workflows/upload-artifacts-dotnet.yml)ワークフローの引数となるJSON文字列を出力する。

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

名前|必須|デフォルト|説明
-|-|-|-
version|**true**|-|バージョンを表す文字列。
version-major|**true**|-|メジャーバージョンを表す数値。

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
      dotnet-version: 9.0.100-rc.2.24474.11
      version: '1.0.0'
      release: true
      suffix: v1.0.0
    secrets:
      AZURE_ARTIFACT_PAT: ${{ secrets.AZURE_ARTIFACT_PAT }}
      NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
dotnet-version|false|9.0.100-rc.2.24474.11|インストールする.NET SDKバージョン。
version|**true**|-|バージョンを表す文字列。
release|**true**|-|安定版リリースかどうか。
suffix|**true**|-|アップロードする成果物名の末尾に追加する文字列。

#### 環境変数

なし

#### シークレット

名前|必須|デフォルト|説明
-|-|-|-
AZURE_ARTIFACT_PAT|**true**|-|「Packaging」スコープの読み書きを許可したAzure DevOps Personal Access Token。
NUGET_API_KEY|**true**|-|「Push」スコープを許可したNuGet APIキー。

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
      echo '${{ needs.main.outputs.tag }}'
      echo '${{ needs.main.outputs.dotnet }}'
      echo '${{ needs.main.outputs.docker }}'
```

#### 引数

なし

#### 環境変数

なし

#### 出力

名前|説明
-|-
version|バージョンを表す文字列。
version-major|メジャー番号を表す数値。
release|安定版リリースかどうか。
tag|gitタグ名。
dotnet|.NETファイルが含まれているかどうか。
docker|Dockerfileが含まれているかどうか。

### release.yml

GitHubリリースを作成する再利用可能なワークフローです。GitHub Actions Artifactsにファイルが存在する場合、そのファイルをアップロードします。

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
      tag: v1.0.0
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
version|**true**|-|バージョンを表す文字列。
tag|**true**|-|gitタグ名。

#### 環境変数

なし

#### 出力

なし

### upload-artifacts-dotnet.yml

.NETの発行により出力されたファイルを、GitHub Actions Artifactsにアップロードする再利用可能なワークフローです。`Source/${{ project }}/${{ project }}.csproj`を前提とします。

```yaml
on:
  push:
    branches:
      - main

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/upload-artifacts-dotnet.yml@main
    with:
      dotnet-version: 9.0.100-rc.2.24474.11
      runs-on: ubuntu-latest
      project: ProjectName
      target-platform-identifier: none
      target-platform-version: ''
      os: win
      architecture: x64
      workload-restore: false
      version: '1.0.0'
      suffix: v1.0.0
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
dotnet-version|false|9.0.100-rc.2.24474.11|インストールする.NET SDKバージョン。
runs-on|false|ubuntu-latest|ランナー環境。
project|**true**|-|プロジェクト名。
target-platform-identifier|false|none|プラットフォーム識別子。
target-platform-version|false|-|プラットフォームバージョンを表す文字列。
os|**true**|-|OSの名前。（ランタイム識別子）
architecture|**true**|-|アーキテクチャ名。（ランタイム識別子）
workload-restore|false|false|dotnet workload restoreを実行するかどうか。
version|**true**|-|バージョンを表す文字列。
suffix|**true**|-|アップロードする成果物名の末尾に追加する文字列。

#### 環境変数

なし

#### 出力

なし

### upload-nuget-library.yml

```yaml
on:
  push:
    branches:
      - main

permissions: {}

jobs:
  main:
    uses: finphie/Actions/.github/workflows/upload-nuget-library.yml@main
    with:
      dotnet-version: 9.0.100-rc.2.24474.11
      version: '1.0.0'
      release: true
    secrets:
      AZURE_ARTIFACT_PAT: ${{ secrets.AZURE_ARTIFACT_PAT }}
      NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
```

#### 引数

名前|必須|デフォルト|説明
-|-|-|-
dotnet-version|false|9.0.100-rc.2.24474.11|インストールする.NET SDKバージョン。
version|**true**|-|バージョンを表す文字列。
release|**true**|-|安定版リリースかどうか。

#### 環境変数

なし

#### シークレット

名前|必須|デフォルト|説明
-|-|-|-
AZURE_ARTIFACT_PAT|**true**|-|「Packaging」スコープの読み書きを許可したAzure DevOps Personal Access Token。
NUGET_API_KEY|**true**|-|「Push」スコープを許可したNuGet APIキー。

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
