# ViewllerJS

## English

DOCUMENTATION: https://sites.google.com/view/viewllerjs/home

If you have any impressions after using it, please contact [Twitter][0].

[0]:https://twitter.com/HajimeOhyake

### This is a framework for creating Web applications on a View basis. (IE 11 not supported)

### Getting started
- Please add "./node_modules/.bin" to your PATH as common knowledge of node.js.

- First, create a directory for the application.
```
$ mkdir viewller-apps
```
- Enter the created directory.
```
$ cd viewller-apps
```
- Initialize npm, Install the ViewllerJS npm module.
```
$ npm init  
$ npm i --save viewller
```
(Wait for a while.)

- It puts it into the compile standby state.
```
$ viewller -w
```
- Start runserver for debugging and production environment. Start with 'node-dev' on development mode. Start with 'forever' on production environment. Default display to sorry view(underconstruction) on production environment.
```
$ viewller -a
```
- Terminate the process at forever do this.
```
$ viewller -t
```
- Switch the production environment to sorry mode.
```
$ viewller -s
```
- Switch the production environment to normal mode.
```
$ viewller -n
```
- Deploy the development environment to the production environment.
```
$ viewller -d
```
- display rollback number.
```
$ viewller -l
```
- Rollback the production environment.
```
$ viewller -r [rollback No.]
```

- It is set by searching for a port number that can be used after port 5000.

Development environment  
[Application directory]/config/develop.json

Production environment  
[Application directory]/config/default.json

- Launch runserver in development and production environment. Immediately after creating the application, "Sorry mode" is turned on. In this state, when you browse the production environment, "underconstruction" is displayed. This page can be customized.
```
$ viewller -a
```
- Access by web browser

**http://[IP address of running PC]:5001**
You can connect to the development environment in the above.

**http://[IP address of running PC]:5000**
You can connect to the production environment in the above.


## Tutorial

*comming soon...*


## 日本語

### ViewベースでWebアプリケーションを作成するフレームワークです。
（IE11非対応）

- node.jsのお約束として「./node_modules/.bin」をPATHに追加しておいてくださ。

- アプリケーション用のディレクトリを作成し、その中でnodeの初期化を行います。
```
$ npm init
```
- 次に、ViewllerJSをインストールします。
```
$ npm i viewller
```
- 下記コマンドでCoffeeScriptファイルの修正を監視し、自動コンパイルします。
```
$ viewller -w
```
- 開発環境と本番環境のrun serverが起動します。開発環境は「node-dev」を使って起動されます。本番環境は「forever」を使って起動されます。デフォルトの本番環境は「Sorry mode」になっていて「Underconstruction」が表示されます。
```
$ viewller -a
```
- foreverで起動している本番環境を停止します。
```
$ viewller -t
```
- 本番環境をSorryモードに変更します。
```
$ viewller -s
```
- 本番環境をNormalモードに変更します。
```
$ viewller -n
```
- 開発環境を本番環境にデプロイします。
```
$ viewller -d
```
- 過去にデプロイされた環境を表示します。ロールバックする場合はこの番号を指定します。
```
$ viewller -l
```
- 番号を指定し、本番環境をロールバックします。
```
$ viewller -r [rollback No.]
```

- ポート5000以降で使用できるポート番号を検索して設定します。

・開発環境  
[アプリケーションディレクトリ}/config/develop.json

・本番環境  
[アプリケーションディレクトリ}/config/default.json

- アプリケーションを作成直後は、「Sorry mode」がオンになっています。この状態で本番環境をブラウズすると、 "underconstruction"が表示されます。このページはカスタマイズすることができます。
```
$ viewller -a
```
- Webブラウザで確認

以下で開発環境に繋がります。
**http://[実行しているPCのIPアドレス]:5001**

以下で本番環境に繋がります。
**http://[実行しているPCのIPアドレス]:5000**


## チュートリアル

*絶賛、作成中*


## Licence

The MIT License (MIT) Copyright (c) 2018 おおやけハジメ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

