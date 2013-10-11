---
layout: default
---

<ul>
  {{# blog.all.sort }}
  <li>
    <h2><a href="{{url}}">{{title}}</a></h2>
    {{{ summary }}}
    <a href="{{url}}">read post...</a>
  </li>
  <br/>
  <hr class="style-two">
  {{/ blog.all.sort }}
</ul>


<!-- {{# blog.paginator.sort }}
<div class="page">
  <h3 class="title"><a href="{{url}}">{{title}}</a></h3><h5 class="align-even"><span class="date">{{ date }}</span></h5>
  {{{ summary }}}
  <div class="more">
    <a href="{{url}}" class="btn">read post..</a>
  </div>
  <br/>
  <hr class="style-two">
</div>
{{/ blog.paginator.sort }}

{{# page.next }}
  Newer: <a href="{{ url }}">{{ title }}</a>
{{/ page.next }} -->