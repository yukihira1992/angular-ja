# サービスと依存性の注入のイントロダクション {@a introduction-to-services-and-dependency-injection}

*サービス*は、アプリケーションが必要とするあらゆる値、関数、機能を含む幅広いカテゴリーです。
サービスは通常、目的が明確な小規模のクラスです。
特定の作業を行い、適切に処理するべきです。

Angular はサービスとコンポーネントを区別してモジュール性と再利用性を高めます。
コンポーネントのビュー関連の機能を他の種類の処理と分離することで、コンポーネントクラスをリーンで効率的にすることができます。

コンポーネントの仕事はユーザー体験を可能にして、それ以上のことをしないことです。
コンポーネントは、(テンプレートによってレンダリングされた)ビューと(しばしばモデルの概念を含む)アプリケーションロジックを仲介するために、データバインディングのプロパティとメソッドを提示する必要があります。

コンポーネントはサーバーからデータを取得したり、ユーザーの入力を検証したり、コンソールに直接ログするなど、特定のタスクをサービスに委任することができます。
このような処理のタスクを*注入可能なサービスクラス*で定義することにより、これらのタスクを任意のコンポーネントで使用できるようにします。
さまざまな状況に応じて同じ種類のサービスの異なるプロバイダーを注入することで、アプリケーションの適応性を高めることもできます。

Angularはこれらの原則を*強制*しません。
Angularはアプリケーションロジックをサービスに組み込むことを容易にし、*依存性の注入*でコンポーネントからこれらのサービスを利用できるようにすることで、これらの原則に*倣う*のに役立ちます。

## サービスの例

次に、ブラウザコンソールにログを記録するサービスクラスの例を示します。

<code-example header="src/app/logger.service.ts (class)" path="architecture/src/app/logger.service.ts" region="class"></code-example>

サービスは他のサービスに依存することがあります。
たとえば、`HeroService` は `Logger` サービスに依存し、`BackendService` を使ってヒーローを取得します。
そのサービスは、サーバーからヒーローを非同期的に取り出すための `HttpClient` サービスに依存するかもしれません。

<code-example header="src/app/hero.service.ts (class)" path="architecture/src/app/hero.service.ts" region="class"></code-example>

## 依存性の注入 (DI)

<div class="lightbox">

<img alt="Service" class="left" src="generated/images/guide/architecture/dependency-injection.png">

</div>

DI は Angular フレームワークとつながり、必要なサービスやその他のものを新しいコンポーネントに提供するためにあらゆる場所で使用されます。
コンポーネントはサービスを消費します。つまり、サービスをコンポーネントに*注入*して、コンポーネントにそのサービスクラスへのアクセスを与えることができます。

クラスをサービスとして Angular で定義するには、  `@Injectable()` デコレーターを使用して Angular が*依存関係*としてコンポーネントにそれを挿入できるようにするメタデータを提供します。
同様に、コンポーネントや他のクラス(別のサービス、パイプ、NgModuleなど)が依存関係を*持っている*ことを示すには、 `@Injectable()` デコレーターを使用します。

*  *インジェクタ* は主なメカニズムです。
   Angular はブートストラップ処理中にアプリケーション全体のインジェクターを作成し、必要に応じて追加のインジェクターを作成します。
   インジェクターを作成する必要はありません。

*  インジェクターは依存関係を作成し、可能であれば再利用する依存関係インスタンスの*コンテナ*を保持します。
*  *プロバイダー* は、インジェクターに依存性を取得または作成する方法を伝えるオブジェクトです。

あなたのアプリケーションで必要な依存関係がある場合は、アプリケーションのインジェクターにプロバイダーを登録しなければならず、その結果インジェクターはプロバイダーを使用して新しいインスタンスを作成できます。
サービスの場合、プロバイダーは通常、サービスクラスそのものです。

<div class="alert is-helpful">

依存関係はサービスである必要はありません。たとえば、関数や値などです。

</div>

Angular は、コンポーネントクラスの新しいインスタンスを作成するとき、コンストラクターのパラメータタイプを調べることによってコンポーネントが必要とするサービスやその他の依存関係を判断します。
たとえば、`HeroListComponent` のコンストラクターには　`HeroService` が必要です。

<code-example header="src/app/hero-list.component.ts (constructor)" path="architecture/src/app/hero-list.component.ts" region="ctor"></code-example>

Angular はコンポーネントがサービスに依存していることを検出すると、インジェクターにそのサービスの既存のインスタンスがあるかどうかをまずチェックします。
要求されたサービスインスタンスがまだ存在しない場合、インジェクターは登録されたプロバイダーを使用してインスタンスを作成し、サービスを Angular に返す前にインジェクターに追加します。

要求されたサービスがすべて解決されて返されると、Angular はそれらのサービスを引数としてコンポーネントのコンストラクターを呼び出すことができます。

`HeroService`注入のプロセスは、このようになります。

<div class="lightbox">

<img alt="Service" class="left" src="generated/images/guide/architecture/injector-injects.png">

</div>

### サービスの提供 {@a providing-services}

あなたは、使用しようとしているサービスの*プロバイダー*を少なくとも1つ登録する必要があります。
プロバイダーはサービスをどこからでも利用できるようにサービス自体のメタデータの一部にできるし、もしくは、プロバイダーを特定のモジュールまたはコンポーネントに登録できます。
サービスのメタデータ(`@Injectable()` デコレーター内) または`@NgModule()` や `@Component()` メタデータにプロバイダーを登録します。

*  デフォルトでは Angular CLI コマンド [ng generate service](cli/generate) はプロバイダーのメタデータを `@Injectable()` デコレーターに含めることによって、あなたのサービスのためにプロバイダーをルートインジェクターに登録します。
   このチュートリアルでは、この方法を使用して HeroService クラス定義のプロバイダーを登録します。

   <code-example format="typescript" language="typescript">

   &commat;Injectable({
    providedIn: 'root',
   })

   </code-example>

   ルートレベルでサービスを提供すると、Angularは `HeroService` の共有インスタンスを1つ作成し、
   それを求めるクラスに注入します。
   `@Injectable()` メタデータにプロバイダーを登録することは、サービスが使用されない場合にコンパイルされるアプリケーションからサービスを削除してアプリケーションを最適化することを、
   Angularに許可することにもなります。これは *Tree-Shaking* として知られるプロセスです。

*  プロバイダーを[特定の NgModule](guide/architecture-modules) に登録すると、そのNgModule内のすべてのコンポーネントで同じサービスのインスタンスを使用できます。
   このレベルで登録するには、`@NgModule()` デコレーターの `providers` プロパティを使用します。

    <code-example format="typescript" language="typescript">

    &commat;NgModule({
      providers: [
      BackendService,
      Logger
     ],
     &hellip;
    })

    </code-example>

*  コンポーネントレベルでプロバイダーを登録すると、そのコンポーネントの新しいインスタンスごとに新しいサービスインスタンスが取得されます。
   コンポーネントレベルで `@Component()` メタデータの `providers` プロパティにサービスプロバイダーを登録します。

   <code-example header="src/app/hero-list.component.ts (component providers)" path="architecture/src/app/hero-list.component.ts" region="providers"></code-example>

詳細は、[依存性の注入](guide/dependency-injection)セクションを参照してください.

<!-- links -->

<!-- external links -->

<!-- end links -->

@reviewed 2022-02-28
