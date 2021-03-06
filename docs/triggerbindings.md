# TriggerBindings

As per the name, `TriggerBinding`s bind against events/triggers.
`TriggerBinding`s enable you to capture fields from an event and store them as
parameters. The separation of `TriggerBinding`s from `TriggerTemplate`s was
deliberate to encourage reuse between them.

<!-- FILE: examples/triggerbindings/triggerbinding.yaml -->
```YAML
apiVersion: tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: pipeline-binding
spec:
  params:
  - name: gitrevision
    value: $(body.head_commit.id)
  - name: gitrepositoryurl
    value: $(body.repository.url)
  - name: contenttype
    value: $(header.Content-Type)
```


`TriggerBinding`s are connected to `TriggerTemplate`s within an
[`EventListener`](eventlisteners.md), which is where the pod is actually
instantiated that "listens" for the respective events.

## Parameters

`TriggerBinding`s can provide `params` which are passed to a `TriggerTemplate`.
Each parameter has a `name` and a `value`.

## Event Variable Interpolation

TriggerBindings can access values from the HTTP JSON body and the headers using
JSONPath expressions wrapped in `$()`.

These are all valid expressions:
```shell script
$(body.key1)
$(.body.key)
```

These are invalid expressions:
```shell script
.body.key1 # INVALID - Not wrapped in $()
$({body) # INVALID - Ending curly brace absent
```

### Examples

``` shell script

`$(body)` is replaced by the entire body.

$(body) -> "{"key1": "value1", "key2": {"key3": "value3"}, "key4": ["value4", "value5"]}"

$(body.key1) -> "value1"

$(body.key2) -> "{"key3": "value3"}"

$(body.key2.key3) -> "value3"

$(body.key4[0]) -> "value4"

# $(header) is replaced by all of the headers from the event.

$(header) -> "{"One":["one"], "Two":["one","two","three"]}"

$(header.One) -> "one"

$(header.Two) -> "one two three"

$(header.Two.1) -> "two"
```

## Multiple Bindings

In an [`EventListener`](eventlisteners.md), you may specify multiple bindings as
part of your trigger. This allows you to create reusable bindings that can be
mixed and matched with various triggers. For example, a trigger with one binding
that extracts event information, and another bind that provides deploy
environment information:

```yaml
apiVersion: tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: event-binding
spec:
  params:
  - name: gitrevision
    value: $(body.head_commit.id)
  - name: gitrepositoryurl
    value: $(body.repository.url)
---
apiVersion: tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: prod-env
spec:
  params:
  - name: environment
    value: prod
---
apiVersion: tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: staging-env
spec:
  params:
  - name: environment
    value: staging
---
apiVersion: tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: listener
spec:
  triggers:
    - name: prod-trigger
      bindings:
        - name: event-binding
        - name: prod-env
      template:
        name: pipeline-template
    - name: staging-trigger
      bindings:
        - name: event-binding
        - name: staging-env
      template:
        name: pipeline-template
```
