## Telegram Sender

The application works as a Web server, accepts data via HTTP requests, generates
messages using Jinja2 templates and sends them to the specified Telegram group.

Single entry point for manage telegram credentials and different templates
for different applications (ElastAlert, Prometheus Alertmanager, GitLab alerts, curl, etc).

Make your Telegram notifications beautiful and convenient.

### How to Create and Connect a Telegram Chatbot

Open Telegram messenger, sign in to your account or create a new one.

* Enter `@Botfather` in the search tab and choose this bot.
* Choose or type the /newbot command and send it.
* Choose a name for your bot — your subscribers will see it in the conversation. And choose a username for your bot — the bot can be found by its username in searches. The username must be unique and end with the word “bot.”. Save bot token.
* Add this new bot to you Telegram Group (Chat)
* Get `chat_id`: `curl https://api.telegram.org/bot<YourBOTToken>/getUpdates`. If you don't see `"chat":{"id":`, remove you bot from chat and add it again.

### Example of HELM configuration

`values.yaml`:
```
config:
  my-elastalert:
    chat_id: "-1234567890"
    token: "123456789:aacccccdddfff"
    template: "elastalert"

  my-promalert:
    chat_id: "-1234567890"
    token: "123456789:aacccccdddfff"
    template: "promalert"

  my-gitlab:
    chat_id: "-1234567890"
    token: "123456789:aacccccdddfff"
    template: "gitlab_push_events"

  my-template_1:
    chat_id: "-1234567890"
    token: "123456789:aacccccdddfff"
    template: "my_template_1"

  my-template_2:
    chat_id: "-66564645645"
    token: "22222222:bbbbbbbbcccccccddd"
    template: "my_template_2"


templates:
  default: |-
    {{ data }}

  elastalert: |-
    {%- for key, value in data | dictsort -%}
    *{{ key }}:* `{{ value }}`
    {% endfor %}

  promalert: |-
    {%- set exclude_labels=[
        'send_to_telegram',
        'kubernetes_name',
        'kubernetes_namespace',
        'kubernetes_node',
        'role',
        'job',
        'instance',
        'app',
        'app_kubernetes_io_managed_by',
        'app_kubernetes_io_instance',
        'app_kubernetes_io_name',
        'helm_sh_chart',
        'alertname',
        'severity',
        ]
    -%}
    {% for alert in data['alerts'] %}
    {% if data['status']=='firing' %}🔥{% else %}✅{% endif %} {{ alert['annotations']['description'] }}
    {%- if alert['annotations']['summary'] %}
    {{ alert['annotations']['summary'] -}}
    {% endif %}
    {%- for key, value in alert['labels'] | dictsort %}
    {%- if key not in exclude_labels %}
    *{{ key }}:* `{{ value }}`
    {%- endif -%}
    {% endfor %}
    {% endfor %}

  gitlab_push_events: |-
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
```

### Example config of ElastAlert

Example of ElastAlert `config.yaml` file for send message via telegram-sender:
```
  rules:
    api_v2: |-
      ---
      name: 'user_not_registered'
      type: any
      index: monolog-v2-gelf-production-*
      filter:
        - query:
            query_string:
              query: 'message: "User not registered"'
      alert:
        - post
      http_post_url: "http://telegram-sender/my-elastalert
```

### Example configs of Prometheus Alertmanager

Example of `alertmanager.yml` config file for send message via telegram-sender:
```
  receivers:
    - name: telegram
      webhook_configs:
        - send_resolved: true
          url: http://telegram-sender/my-promalert

  route:
    routes:
      - match:
          send_to_telegram: true
        receiver: telegram
        continue: true
```

Example of `alerting_rules.yml` config file for send message via telegram-sender:
```
  groups:
    - name: "custom-alerts"
      rules:
        - alert: connections-alert
          expr: 'connections_application_count{instance="connections"} > 100'
          for: 1m
          labels:
            severity: critical
            send_to_telegram: true
          annotations:
            description: 'Connections for DB connections is {{ $value }}'
```

### Example configuration of GitLab (Push Events alerts)

* Go to the Admin area in "System Hooks" (https://your-gitlab/admin/hooks)
* Put your telegram-sender url to `URL` (http://telegram-sender/my-gitlab)
* Set check the box for `Push events` only!
* Click the `Add system hook` button

> If you want to receive other events from GitLab, you must make a template for them.

### Example of custom template: `my_template_1`

my_template_1.tpl:
```
This is my template.
Message: "{{ data }}"
```

You can check/test this template with curl:
```
curl \
    -H "Content-Type: application/json" \
    -X POST http://telegram-sender/my-template-1 \
    -d '"Hello world!!!"'
```

Result message:
```
This is my template.
Message: "Hello world!!!"
```

### Example of custom template: `my_template_2`

my_template_2.tpl:
```
Alert: {{ data.alertname }}
Severity: {{ data.severity }}
```

You can check/test this template with curl:
```
curl \
    -H "Content-Type: application/json" \
    -X POST http://telegram-sender/my-template-2 \
    -d '{"alertname":"my_test_alert","severity":"info"}'
```

Result message:
```
Alert: my_test_alert
Severity: info
```



