<!DOCTYPE html>
<html lang='ru'>
<head>
<meta charset='utf-8'>
<meta content='width=device-width, initial-scale=1.0' name='viewport'>
<title>Индикатор загрузки на базе CSS анимации</title>
<link href='data:,' rel='icon'>
<link rel="stylesheet" type="text/css" href="base.css">
<style>
  .spinner1 {
    margin: 1em auto;
    width: 40px;
    height: 40px;
    border-radius: 40px; /* Сделаем элемент круглым */
    border: solid 5px #ddd;
    border-left: solid 5px #999; /* Одна из границ должна отличаться по цвету */
  }
  @keyframes spin {
    0% {
      transform: rotate(0);
    }
    100% {
      transform: rotate(360deg);
    }
  }
  .spinner2 {
    animation-name: spin; /* Применяем анимацию вращения */
    animation-duration: 1s;
    animation-iteration-count: infinite; /* Если не указать, то сделает только одно вращение */
    animation-timing-function: linear; /* Для того, чтобы вращение было равномерным */
  }
</style>

# Индикатор загрузки на базе CSS анимации

23 окт 2021

Для правильной работы индикатора браузер клиента должен поддерживать css анимации.
Поддержку разными версиями браузеров можно проверить [тут](https://caniuse.com/css-animation)

Создадим div элемент с классом _spinner_ &lt;div class="spinner"&gt;&lt;/div&gt;
и применим к нему следующие стили:

```
.spinner {
  margin: 1em auto;
  width: 40px;
  height: 40px;
  border-radius: 40px; /* Сделаем элемент круглым */
  border: solid 5px #ddd;
  border-left: solid 5px #999; /* Одна из границ должна отличаться по цвету */
}
```

В результате получим элемент следующего вида:

<div class='spinner1'></div>

Теперь необходимо добавить вращение с помошью правила _transform: rotate_

```
@keyframes spin {
  0% {
    transform: rotate(0);
  }
  100% {
    transform: rotate(360deg);
  }
}
.spinner {
  animation-name: spin; /* Применяем анимацию вращения */
  animation-duration: 1s; /* Период вращения */
  animation-iteration-count: infinite; /* Если не указать, то сделает только одно вращение */
  animation-timing-function: linear; /* Для того, чтобы вращение было равномерным */
}
```

Если добавить эти стили, то получим следующий результат:

<div class='spinner1 spinner2'></div>
