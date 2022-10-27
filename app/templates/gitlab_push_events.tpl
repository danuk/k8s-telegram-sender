{%- set counter = namespace(added=0, modified=0, removed=0) -%}
{%- set branch = data.ref | replace("refs/heads/","") -%}
*{{ data.user_name }}* pushed to [{{ data.project.path_with_namespace }}/{{ branch }}]({{data.project.web_url}}/-/tree/{{ branch|urlencode }})

{%- for commit in data['commits'] %}
{% if data.total_commits_count > 1 %}*{{ commit.author.name }}: *{% endif %}[{{ commit.title }}]({{ commit.url }})
{%- set counter.added = counter.added + commit.added|length -%}
{%- set counter.modified = counter.modified + commit.modified|length -%}
{%- set counter.removed = counter.removed + commit.removed|length -%}
{% endfor %}

{% if counter.modified %}{{ counter.modified }} files modified {% endif -%}
{% if counter.added %}{{ counter.added }} added {% endif -%}
{% if counter.removed %}{{ counter.removed }} removed {% endif -%}
