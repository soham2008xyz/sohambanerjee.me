---
layout: post
title: Writing cleaner code in Laravel
date: 2020-06-26 08:45:11
categories:
tags: featured development laravel tutorials
image: /assets/article_images/2020-06-26-clean-code-laravel/henri-l-CHt4BMi0-Is-unsplash.jpg
image2: /assets/article_images/2020-06-26-clean-code-laravel/henri-l-CHt4BMi0-Is-unsplash-min.jpg
---
I recently came across [this Twitter thread](http://samuelstancl.me/t/clean-code), where [@samuelstancl](https://twitter.com/samuelstancl) listed tips for writing cleaner code in Laravel, as well as some general Laravel coding advice. These are a great starting point to develop a sense for what's good code and what's bad code - so I collated them below (with code samples), in no particular order.

1. **It's about the _micro_**

Using some "macro" philosophy for structuring your code, like hexagonal architecture or DDD won't save you. A clean codebase is the result of constant good decisions at the micro level.

{:start="2"}
2. **Use lookup tables**

Instead of writing repetitive `else if` statements, use an array to look up the wanted value based on the key you have. The code will be cleaner & more readable and you will see understandable exceptions if something goes wrong. No half-passing edge cases.

{% highlight php %}
// Bad
if ($order->product->option->type === 'pdf') {
    $type = 'book';
} else if ($order->product->option->type === 'epub') {
    $type = 'book';
} else if ($order->product->option->type === 'license') {
    $type = 'license';
} else if ($order->product->option->type === 'artwork') {
    $type = 'creative';
} else if $order->product->option->type === 'song') {
    $type = 'creative';
} else if ($order->product->option->type === 'physical') {
    $type = 'physical';
}

if ($type === 'book') {
    $downloadable = true;
} else if ($type === 'license') {
    $downloadable = true;
} else if $type === 'creative') {
    $downloadable = true;
} else if ($type === 'physical') {
    $downloadable = false;
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
$type = [
    'pdf'      => 'book',
    'epub'     => 'book',
    'license'  => 'license',
    'artwork'  => 'creative',
    'song'     => 'creative',
    'physical' => 'physical',
][$order->product->option->type];

$downloadable = [
    'book'     => true,
    'license'  => true,
    'creative' => true,
    'physical' => false,
][$type];
{% endhighlight %}

{:start="3"}
3. **Return early**

Try to avoid unnecessary nesting by returning a value early. Too much nesting & else statements tend to make code harder to read.

{% highlight php %}
// Bad
if ($notificationSent) {
  $notify = false;
} else if ($isActive) {
  if ($total > 100) {
    $notify = true;
  } else {
    $notify = false;
  } else {
    if ($canceled) {
      $notify = true;
    } else {
      $notify = false;
    }
  }
}

return $notify;
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
if ($notificationSent) {
  return false;
}

if ($isActive && $total > 100) {
  return true;
}

if (! $isActive && $canceled) {
  return true;
}

return false;
{% endhighlight %}

{:start="4"}
4. **Split lines correctly**

Don't split lines at random places, but don't make them too long either. Opening an array with `[` and indenting the values tends to work well. Same with long function parameter values. Other good places to split lines are chained calls and closures.

{% highlight php %}
// Bad
// No line split
return $this->request->session()->get($this->config->get('analytics.campaign_session_key'));

// Meaningless line split
return $this->request
  ->session()->get($this->config->get('analytics.campaign_session_key'));
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
return $this->request->session()->get(
  $this->config->get('analytics.campaign_session_key')
);

// Closure
new EventCollection($this->events->map(function (Event $event) {
  return new Entries\Event($event->code, $event->pivot->data);
}));

// Array
$this->validate($request, [
  'code' => 'string|required',
  'name' => 'string|required',
]);
{% endhighlight %}

{:start="5"}
5. **Don't create useless variables**

Don't create variables when you can just pass the value directly.

{% highlight php %}
// Bad
public function create()
{
  $data = [
    'resource' => 'campaign',
    'generatedCode' => Str::random(8),
  ];

  return $this->inertia('Resource/Create', $data);
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
public function create()
{
  return $this->inertia('Resource/Create', [
    'resource'      => 'campaign',
    'generatedCode' => Str::random(8),
  ]);
}
{% endhighlight %}

{:start="6"}
6. **Create variables when they improve readability**

The opposite of the previous tip. Sometimes the value comes from a complex call and as such, creating a variable improves readability & removes the need for a comment. Remember that context matters & your end goal is readability.

{% highlight php %}
// Bad
Visit::create([
  'url' => $visit->url,
  'referer' => $visit->referer,
  'user_id' => $visit->userId,
  'ip' => $visit->ip,
  'timestamp' => $visit->timestamp,
])->conversion_goals()->attach($conversionData);
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
$visit = Visit::create([
  'url'       => $visit->url,
  'referer'   => $visit->referer,
  'user_id'   => $visit->userId,
  'ip'        => $visit->ip,
  'timestamp' => $visit->timestamp,
]);

$visit->conversion_goals()->attach($conversionData);
{% endhighlight %}

{:start="7"}
7. **Create model methods for business logic**

Your controllers should be simple. They should say things like "create invoice for order". They shouldn't be concerned with the details of how your database is structured. Leave that to the model.

{% highlight php %}
// Bad
// Create invoice for order
DB::transaction(function () use ($order) {
  Sinvoice = $order->invoice()->create();

  $order—>pushStatus(new AwaitingShipping);

  return $invoice;
});
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
$order->createInvoice();
{% endhighlight %}

{:start="8"}
8. **Create action classes**

Let's expand on the previous example. Sometimes, creating a class for a single action can clean things up. Models should encapsulate the business logic related to them, but they shouldn't be too big.

{% highlight php %}
// Bad
public function createInvoice(): Invoice
{
  if ($this->invoice()->exists()) {
    throw new OrderAlreadyHasAnInvoice('Order already has an invoice.');
  }

  return DB::transaction(function () use ($order) {
    $invoice = $order->invoice()->create();

    $order->pushStatus(new AwaitingShipping);

    return $invoice;
  });
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
// Order model
public function createInvoice(): Invoice {
  if ($this->invoice()->exists()) {
    throw new OrderAlreadyHasAnInvoice('Order already has an invoice.');
  }

  return app(CreateInvoiceForOrder::class)($this);
}

// Action class
class CreatelnvoiceForOrder
{
  public function _invoke(Order $order): Invoice
  {
    return DB::transaction(function () use ($order) {
      $invoice = $order->invoice()->create();

      $order->pushStatus(new AwaitingShipping);

      return $invoice;
    });
  }
}
{% endhighlight %}

{:start="9"}
9. **Consider form requests**

Consider using form requests. They're a great place to hide complex validation logic. But beware of exactly that — hiding things. When your validation logic is simple, there's nothing wrong with doing it in the controller. Moving it to a form request makes it less explicit.

{:style="margin-bottom: 2em"}
{% highlight php %}
/**
 * Get the validation rules that apply to the request.
 *
 * @return array
 */
public function rules()
{
  return [
    'title' => 'required|unique:posts|max:255',
    'body'  => 'required',
  ];
}
{% endhighlight %}

{:start="10"}
10. **Use events**

Consider offloading some logic from controllers to events. For example, when creating models. The benefit is that creating these models will work the same everywhere (controllers, jobs, ...) and the controller has one less worry about the details of the DB schema.

{% highlight php %}
// Bad
// Only works in this place & concerns it with
// details that the model should care about.
if (! isset($data['name'])) {
  $data['name'] = $data['code'];
}

$conversion = Conversion::create($data);
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
$conversion = Conversion::create($data);

// Model
class ConversionGoal extends Model
{
  public static function booted()
  {
    static::creating(function (self $model) {
      $model->name ??= $model->code;
    });
  }
}
{% endhighlight %}

{:start="11"}
11. **Extract methods**

If some method is too long or complex, and it's hard to understand what exactly is happening, split the logic into multiple methods.

{:style="margin-bottom: 2em"}
{% highlight php %}
public function handle(Request $request, Closure $next)
{
  // We extracted 3 tong methods into separate methods.
  $this->trackVisitor();
  $this->trackCampaign();
  $this->trackTrafficSource($request);

  $response = $next($request);

  $this->analytics->log($request);

  return $response;
}
{% endhighlight %}

{:start="12"}
12. **Create helper functions**

If you repeat some code a lot, consider if extracting it to a helper function would make the code cleaner.

{:style="margin-bottom: 2em"}
{% highlight php %}
// app/helpers.php, autoloaded in composer.json
function money(int $amount, string $currency = null): Money
{
  return new Money($amount, $currency ?? config('shop.base_currency'));
}

function html2text($html = ''): string
{
  return str_replace('&nbsp;', ' ', strip_tags($html));
}
{% endhighlight %}

{:start="13"}
13. **Avoid helper _classes_**

Sometimes people put helpers into a class. Beware, it can get messy. This is a class with only static methods used as helper functions. It's usually better to put these methods into classes with related logic or just keep them as global functions.

{% highlight php %}
// Bad
class Helper
{
  public function convertCurrency(Money $money, string $currency): self
  {
    $currencyConfig = config("shop.currencies.$currency");
    $decimalDiff = ...

    return new static(
      (int) round($money->baseValue() * $currencyConfig[value] * 10**$decimalDiff, 0),
      $currency
    );
  }
}

// Usage
use App\Helper;
Helper::convertCurrency($total, 'EUR');
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
class Money
{
  // the other money/currency logic

  public function convertTo(string $currency): self
  {
    $currencyConfig = config("shop.currencies.$currency");
    $decimalDiff = ...

    return new static(
      (int) round($this->baseValue() * $currencyConfig[value * 10**$decimalDiff, 0),
      $currency
    );
  }
}

// Usage
$EURtotal = $total->convertTo('EUR');
{% endhighlight %}

{:start="14"}
14. **Dedicate a weekend towards learning proper OOP**

Know the difference between static/instance methods & variables and private/protected/public visibility. Also learn how Laravel uses magic methods. You don't need this as a beginner, but as your code grows, it's crucial.

{:start="15"}
15. **Don't just write procedural code in classes**

This ties the previous tweet with the other tips here. OOP exists to make your code more readable, use it. Don't just write 400 line long procedural code in controller actions.

{:start="16"}
16. **Read up on things like SRP & follow them to _reasonable_ extent**

Avoid having classes that deal with many unrelated things. But, for the love of god, don't create a class for every single thing. You're trying to write clean code. You're not trying to please the separation gods.

{:start="17"}
17. **Avoid too many parameters in functions**

When you see a function with a huge amount of parameters, it can mean:

1. The function has too many responsibilities. Separate.
2. The responsibilities are fine, but you should refactor the long signature.

Below are two tactics for the fixing second case.

{:start="18"}
18. **Use Data Transfer Objects (DTOs)**

Rather than passing a huge amount of arguments in a specific order, consider creating an object with properties to store this data. Bonus points if you can find that some behavior can be moved into to this object.

{% highlight php %}
// Bad
public function log($url, $route_name, $route_data, $campaign_code, $traffic_source, $referer, $user_id, $visitor_id, $ip, $timestamp)
{
  // ...
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
public function log(Visit $visit)
{
  // ...
}

class Visit
{
  public string $url;
  public ?string $routeName;
  public array $routeData;

  public ?string $campaign;
  public array $trafficSource[];

  public ?string $referer;
  public ?string $userId;
  public string $visitorId;
  public ?string $ip;

  public Carbon $timestamp;

  // ...
}
{% endhighlight %}

{:start="19"}
19. **Create fluent objects**

You can also create objects with fluent APIs. Gradually add data by with separate calls, and only require the absolute minimum in the constructor. Each method will return `$this`, so you can stop at any call.

{:style="margin-bottom: 2em"}
{% highlight php %}
Visit::make($url, $routeName, $routeData)
  ->withCampaign($campaign)
  ->withTrafficSource($trafficSource)
  ->withReferer($referer)
  // ... etc
{% endhighlight %}

{:start="20"}
20. **Use custom collections**

Creating custom collections can be a great way to achieve more expressive syntax. Consider this example with order totals.

{% highlight php %}
// Bad
$total = $order->products->sum(function (OrderProduct $product) {
  return $product->price * $product->quantity * (1 + $product->vat_rate);
});
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
$order->products->total();

class OrderProductCollection extends Collection
{
  public function total()
  {
    $this->sum(function (OrderProduct $product) {
      return $product->price * $product->quantity * (1 + $product->vat_rate);
    });
  }
}
{% endhighlight %}

{:start="21"}
21. **Don't use abbreviations**

Don't think that long variable/method names are wrong. They're not. They're expressive. Better to call a longer method than a short one and check the docblock to understand what it does. Same with variables. Don't use nonsense 3-letters abbreviations.

{% highlight php %}
// Bad
$ord = Order::create($data);

// ...

$ord->notify();
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
$order = Order::create($data);

// ...

$order->sendCreatedNotification();
{% endhighlight %}

{:start="22"}
22. **Try to only use CRUD actions**

If you can, only use the 7 CRUD actions in your controllers. Often even fewer. Don't create controllers with 20 methods. More shorter controllers is better.

<iframe src="https://www.youtube.com/embed/MF0jFKvS4SI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

{:start="23" style="margin-top: 2em"}
23. **Use expressive names for methods**

Rather than thinking "what can this object do", think about "what can be done with this object". Exceptions apply, such as with action classes, but this is a good rule of thumb.

<iframe src="https://www.youtube.com/embed/dfgtKb-VpRk" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

{:style="margin-top: 1em"}
{% highlight php %}
// Bad
$gardener->water($plant);

$orderManager->lock($order);
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
$plant->water();

$order->lock();
{% endhighlight %}

{:start="24"}
24. **Create single-use traits**

Adding methods to classes where they belong is cleaner than creating action classes for everything, but it can make the classes grow big. Consider using traits. They're meant _primarily_ for code reuse, but there's nothing wrong with single-use traits.

{:style="margin-bottom: 2em"}
{% highlight php %}
class Order extends Model
{
  use HasStatuses;

  // ...
}

trait HasStatuses
{
  public static function bootHasStatuses() { ... }
  public static $statusMap = [ ... ];
  public static $paymentStatusMap = [ ... ];
  public static function getStatusId($status) { ... }
  public static function getPaymentStatusId($status): string { ... }
  public function statuses() { ... }
  public function payment_statuses() { ... }
  public function getStatusAttribute(): OrderStatusModel { ... }
  public function getPaymentStatusAttribute(): OrderPaymentStatus { ... }
  public function pushStatus($status, string $message = null, bool $notification = null) { ... }
  public function pushPaymentStatus($status, string $note = null) { ... }
  public function status(): OrderStatus { ... }
  public function paymentStatus(): PaymentStatus { ... }
}
{% endhighlight %}

{:start="25"}
25. **Create single-use Blade includes**

Similar to single-use traits. This tactic is great when you have a very long template and you want to make it more manageable. There's nothing wrong with `@include`-ing headers and footers in layouts, or things like complex forms in page views.

{:start="26"}
26. **Import namespaces instead of using aliases**

Sometimes you may have multiple classes with the same name. Rather than importing them with an alias, import the namespaces.

{% highlight php %}
// Bad
use App\Types\Entries\Visit as VisitEntry;
use App\Storage\Database\Models\Visit as VisitModel;

class DatabaseStorage
{
  public function log(VisitEntry $visit)
  {
    $visitModel = VisitModel::create([
      // ...
    ]);
  }
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
use App\Types\Entries;
use App\Storage\Database\Models;

class DatabaseStorage
{
  public function log(Entries\Visit $visit)
  {
    $visitModel = Models\Visit::create([
      // ...
    ]);
  }
}
{% endhighlight %}

{:start="27"}
27. **Create query scopes for complex `where()`s**

Rather than writing complex `where()` clauses, create query scopes with expressive names. This will make your e.g. controllers have to know less about the database structure and your code will be cleaner.

{% highlight php %}
// Bad
Order::whereHas('status', function ($status) {
  return true$status->where('canceled', true);
})->get();
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
Order::whereCanceled()->get();

class Order extends Model
{
  public function scopeWhereCanceled(Builder $query)
  {
    return $query>whereHas('status', function ($status) {
      return $status->where('canceled', true);
    });
  }
}
{% endhighlight %}

{:start="28"}
28. **Don't use model methods to retrieve data**

If you want to retrieve some data from a model, create an accessor. Keep methods for things that _change_ the model in some way.

{% highlight php %}
// Bad
$user->gravatarUrl();

class User extends Authenticable
{
  // ...

  public function gravatarUrl()
  {
    return "https://www.gravatar.com/avatar/" . md5(strtolower(trim($this->email)));
  }
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
Suser->gravatar_url;

class User extends Authenticable
{
  // ...

  public function getGravatarUrlAttribute()
  {
    return "https://www.gravatar.com/avatar/" . md5(strtolower(trim($this->email)));
  }
}
{% endhighlight %}

{:start="29"}
29. **Use custom config files**

You can store things like "results per page" in config files. Don't add them to the app config file though. Create your own. e.g. In an e-commerce project, you can use `config/shop.php`.

{:style="margin-bottom: 2em"}
{% highlight php %}
// config/shop.php
return [
  'vat rates' => [
    0.21,
    0.15,
    0.10,
    0.0,
  ],
  'fee_vat_rate' => 0.21,

  'image_sizes' => [
    'base' => 500, // detail
    't1'   => 250, // index
    't2'   => 50,  // search
  ],
];
{% endhighlight %}

{:start="30"}
30. **Don't use a controller namespace**

Instead of writing controller actions like `PostController@index`, use the callable array syntax `[PostController::class, 'index']`. You will be able to navigate to the class by clicking `PostController`.

{% highlight php %}
// Bad
Route::get('/posts', 'PostController@index');
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
Route::get('/posts', [PostController::class, 'index']);
{% endhighlight %}

{:start="31"}
31. **Consider single-action controllers**

If you have a complex route action, consider moving it to a separate controller. For `OrderController::create`, you'd create `CreateOrderController`. Another solution is to move that logic to an action class — do what works best in your case.

{:style="margin-bottom: 2em"}
{% highlight php %}
// We use class syntax from the tip above.
Route::post('/orders/', CreateOrderController::class);

class CreateOrderController
{
  public function _invoke(Request $request)
  {
    // ...
  }
}
{% endhighlight %}

{:start="32"}
32. **Be friends with your IDE**

Install extensions, write annotations, use typehints. Your IDE will help you with getting your code working correctly, which lets you spend more energy on writing code that's also readable.

{:style="margin-bottom: 2em"}
{% highlight php %}
$products = Product::with('options')->cursor();

foreach ($products as $product) {
  /** @var Product $product */
  if ($product->options->isEmpty()) {
    // ...
  }
}

///////////////////////////

foreach (Order::whereDoesntHave('invoice')->whereIn('id', $orders->pluck('id'))->get() as $order) {
  /** @var Order $order */
  $order->createInvoice();

  // ...
}

///////////////////////////

$productImage
  ->help('Max 2 MB')
  ->store(function (NovaRequest $request, ProductModel $product) {
    /** @var UploadedFile $image */
    $image = $request->image;

    // ...
  });
{% endhighlight %}

{:start="33"}
33. **Use short operators**

PHP has many great operators that can replace ugly `if` checks. Memorize them.

{% highlight php %}
// Bad
// truthy test
if (! $foo) {
  $foo = 'bar';
}

// null test
if (is_null($foo)) {
  $foo = 'bar';
}

// isset test
if (! isset($foo)) {
  $foo = 'bar';
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
// truthy test
$foo = $foo ?: 'bar';

// null test
$foo = $foo ?? 'bar';
// PHP 7.4
$foo ??= 'bar';

// isset test
$foo = $foo ?? 'bar';
// PHP 7.4
$foo ??= 'bar';
{% endhighlight %}

{:start="34"}
34. **Decide if you like spaces around operators**

Above you can see that I use space between `!` and the value I'm negating. I like this, because it makes it clear that the value is being negated. I do the same around dots. Decide if you like it. It can (imo) clean up your code.

{:start="35"}
35. **Helpers instead of facades**

Consider using helpers instead of facades. They can clean things up. This is largely a matter of personal preference, but calling a global function instead of having to import a class and statically call a method feels nicer to me. Bonus points for `session('key')` syntax.

{% highlight php %}
// Bad
Cache::get('foo');
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
cache()->get('foo');
// Better
cache('foo');
{% endhighlight %}

{:start="36"}
36. **Create custom Blade directives for business logic**

You can make your Blade templates more expressive by creating custom directives. For example, rather than checking if the user has the admin role, you could use `@admin`.

{% highlight php %}
// Bad
@if(auth()->user()->hasRole('admin'))
  // ...
@else
  // ...
@endif
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
@admin
  // ...
@else
  // ...
@endadmin
{% endhighlight %}

{:start="37"}
37. **Avoid queries in Blade when possible**

Sometimes you may want to execute DB queries in blade. There are some ok use cases for this, such as in layout files. But if it's a view returned by a controller, pass the data in the view data instead.

{% highlight php %}
// Bad
@foreach(Product::where('enabled', false)->get() as $product)
  // ...
@endforeach
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
// Controller
return view('foo', [
  'disabledProducts' => Product::where('enabled', false)->get(),
]);

// View
@foreach($disabledProducts as $product)
  // ...
@endforeach
{% endhighlight %}

{:start="38"}
38. **Use strict comparison**

ALWAYS use strict comparison (`===` and `!==`). If needed, cast things go the correct type before comparing. Better than weird `==` results. Also consider enabling strict types in your code. This will prevent passing variables of wrong data types to functions.

{% highlight php %}
// Bad
$foo == 'bar';
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
$foo === 'bar';
// Better
declare(strict_types=1);
{% endhighlight %}

{:start="39"}
39. **Use docblocks only when they clarify things**

Many people will disagree with this, because they do it. But it makes no sense. There's no point in using docblocks when they don't give any extra information. If the typehint is enough, don't add a docblock. That's just noise.

{% highlight php %}
// Bad
// No types at all
function add_5($foo)
{
  return $foo + 5;
}

// The @param annotation adds precisely 0% value and 100% noise.
/**
 * Add 5 to a number.
 *
 * @param int $foo
 * @return int
 */
function add_5(int $foo): int
{
  return $foo + 5;
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
// Everything is clear without a docblock
function add_5(int $foo)
{
  return $foo + 5;
}

// The typehint said as much as it could & the annotation said even more.
/**
 * Turn words into a sentence.
 *
 * @param string[] $words
 * @return string
 */
function sentenceFromWords(array $words): string
{
  return implode(' ', $words) . '.';
}

// Personal favourite. Only use the annotations that bring value. Don't use description or @return just because it's so common.
/** @param string[] $words */
function sentenceFromWords(array $words): string
{
  return implode(' ', $words) . '.';
}
{% endhighlight %}

{:start="40"}
40. **Have a single source of truth for validation rules**

If you validate some resource's attributes on multiple places, you definitely want to centralize these validation rules, so that you don't change them in one place but forget about the other places. I often find myself keeping validation rules in a method on the model. This lets me reuse them wherever I may need - including in controllers or form requests.

{:style="margin-bottom: 2em"}
{% highlight php %}
class Reply extends Model
{
  public static function getValidationRules(): array
  {
    return [
      'thread_id' => ['required', 'integer'],
      'user_id'   => ['required', 'integer'],
      'body'      => ['required', 'string', new SpamRule()],
    ];
  }
}
{% endhighlight %}

{:start="41"}
41. **Use collections when they can clean up your code**

Don't turn all arrays into collections just because Laravel offers them, but DO turn arrays into collections when you can make use of collection syntax to clean up your code.

{:style="margin-bottom: 2em"}
{% highlight php %}
$collection = collect([
  ['name' => 'Regena', 'age' => null],
  ['name' => 'Linda', 'age' => 14],
  ['name' => 'Diego', 'age' => 23],
  ['name' => 'Linda', 'age' => 84],
]);

$collection->firstWhere('age', '>=', 18);
{% endhighlight %}

{:start="42"}
42. **Write functional code when it benefits you**

Functional code can both clean things up and make them impossible to understand. Refactor common loops into functional calls, but don't write stupidly complex reduce()s just to avoid writing a loop. There's a use case for both.

{% highlight php %}
// Bad
return array_unique(array_reduce($keywords, function ($result, $keyword) {
  return array_merge($result, array_reduce($this->variantGenerators, function ($result2, $generator) use ($keyword) {
    return array_merge($result2, array_map(function ($variant) {
      return strtolower($variant);
    }, $generator::getVariants($keyword)));
  }, []));
}, []));
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
return $this->items()->reduce(function (Money $sum, OrderItem $item) {
  return $sum->addMoney($item->subtotal());
}, money(0, $this->currency));
{% endhighlight %}

{:start="43"}
43. **Comments usually indicate poor code design**

Before writing a comment, ask yourself if you could rename some things or create variables to improve readability. If that's not possible, write the comment in a way that both your colleagues and you will understand in 6 months.

{:start="44"}
44. **Context matters**

Above I said that moving business logic to action/service classes is good. But context matters. Here's code design advice from a popular "Laravel best practices" repo. There's absolutely no reason to put a 3-line check into a class. That's just overengineered.

{% highlight php %}
// Bad
public function store(Request $request)
{
  $this->articleService->handleUploadedImage($request->file('image'));
}

class ArticleService
{
  public function handleUploadedImage($image)
  {
    if (!is_null($image)) {
      $image->move(public_path('images') . 'temp');
    }
  }
}
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
// Good
public function store(Request $request)
{
  if ($request->hasFile('image')) {
    $request->file('image')->move(public_path('images') . 'temp');
  }

  // ...
}
{% endhighlight %}

{:start="45"}
45. **Use only what helps you and ignore everything else**

Your goal to write more readable code. Your goal is NOT to do what someone said on the internet. These tips are just tactics that tend to help with clean code. Keep your end goal in mind and ask yourself "is this better?"
