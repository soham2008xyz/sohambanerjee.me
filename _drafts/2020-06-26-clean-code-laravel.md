---
layout: post
title: Writing cleaner code in Laravel
date: 2020-06-26 08:45:11
categories:
tags: featured development laravel tutorials
image: /assets/article_images/2020-06-26-clean-code-laravel/henri-l-CHt4BMi0-Is-unsplash.jpg
image2: /assets/article_images/2020-06-26-clean-code-laravel/henri-l-CHt4BMi0-Is-unsplash-min.jpg
excerpt:
  In this post, I'll list tactics you can use to write cleaner code in Laravel. As you use them repeatedly, you'll develop a sense for what's good code and what's bad code. I'll also sprinkle some general Laravel code advice in between these tactics.
---
I recently came across [this Twitter thread](http://samuelstancl.me/t/clean-code), where [@samuelstancl](https://twitter.com/samuelstancl) listed tips for writing cleaner code in Laravel, as well as some general Laravel coding advice. These are a great starting point to develop a sense for what's good code and what's bad code - so I collated them below (with code samples), in no particular order.

1. **It's about the _micro_**

Using some "macro" philosophy for structuring your code, like hexagonal architecture or DDD won't save you. A clean codebase is the result of constant good decisions at the micro level.

{:start="2"}
2. **Use lookup tables**

Instead of writing repetitive `else if` statements, use an array to look up the wanted value based on the key you have. The code will be cleaner & more readable and you will see understandable exceptions if something goes wrong. No half-passing edge cases.

{% highlight php %}
/* Bad */
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
/* Good */
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
/* Bad */
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
/* Good */
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
/* Bad */
// No line split
return $this->request->session()->get($this->config->get('analytics.campaign_session_key'));

// Meaningless line split
return $this->request
  ->session()->get($this->config->get('analytics.campaign_session_key'));
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
/* Good */
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
/* Bad */
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
/* Good */
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
/* Bad */
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
/* Good */
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
/* Bad */
// Create invoice for order
DB::transaction(function () use ($order) {
  Sinvoice = $order->invoice()->create();

  $order—>pushStatus(new AwaitingShipping);

  return $invoice;
});
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
/* Good */
$order->createInvoice();
{% endhighlight %}

{:start="8"}
8. **Create action classes**

Let's expand on the previous example. Sometimes, creating a class for a single action can clean things up. Models should encapsulate the business logic related to them, but they shouldn't be too big.

{% highlight php %}
/* Bad */
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
/* Good */
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
/* Bad */
// Only works in this place & concerns it with
// details that the model should care about.
if (! isset($data['name'])) {
  $data['name'] = $data['code'];
}

$conversion = Conversion::create($data);
{% endhighlight %}
{:style="margin-bottom: 2em"}
{% highlight php %}
/* Good */
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
