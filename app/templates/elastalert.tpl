{%- for key, value in data | dictsort -%}
*{{ key }}:* `{{ value }}`
{% endfor %}
