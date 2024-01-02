<!DOCTYPE html>
<html lang='ru'>
<head>
  <meta charset='utf-8'>
  <meta content='width=device-width, initial-scale=1.0' name='viewport'>
  <title>Компилируем класс вручную</title>
  <link rel="stylesheet" href="base.css">
  <style>
    table { border-collapse: collapse }
    table * { border: solid 1px #ddd }
    table th { font-weight: normal }
    table td { padding: 0.2em 0.3em }
  </style>
</head>

# Компилируем класс вручную

6 янв 2024

Возьмем для примера следующий класс

```
public final class Test {
  public static void main(String[] args) {
    System.out.println("Hello World!");
  }
}
```

Попробуем "скомпилировать его вручную", создав class-файл без компилятора javac.

## Формат class-файла

Формат class-файла описан в спецификации JVM и его можно найти по ссылке
[The class File Format](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html).
Его можно описать следующей структурой

```
ClassFile {
    u4             magic;
    u2             minor_version;
    u2             major_version;
    u2             constant_pool_count;
    cp_info        constant_pool[constant_pool_count-1];
    u2             access_flags;
    u2             this_class;
    u2             super_class;
    u2             interfaces_count;
    u2             interfaces[interfaces_count];
    u2             fields_count;
    field_info     fields[fields_count];
    u2             methods_count;
    method_info    methods[methods_count];
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}
```

Поле magic является константой и принимает значение 0xcafebabe. Поля minor_version и major_version
указывают на версию данного class-файла. Мы будем пытаться создать class-файл для Java 8. В спецификации
указано, что для данной версии java minor_version = 0x0000 и major_version = 0x0034.

Тут же, сразу и без дополнительных вычислений можно задать значения для полей: access_flags, interfaces_count,
interfaces, fields_count, fields.

access_flags - поле, указывающее на модификаторы доступа и тип содержимого в class-файле (обычный это класс,
либо enum, interface или аннотация). Данное поле это битовая маска из значений из следующей таблицы

| flag name      | value  | description                                                   |
| ---            | ---    | ---                                                           |
| ACC_PUBLIC     | 0x0001 | public класс                                                  |
| ACC_FINAL      | 0x0010 | final класс                                                   |
| ACC_SUPER      | 0x0020 | для спец. обработки вызова методов родителя при invokespecial |
| ACC_INTERFACE  | 0x0200 | это интерфейс                                                 |
| ACC_ABSTRACT   | 0x0400 | абстрактный класс                                             |
| ACC_SYNTHETIC  | 0x1000 | synthetic; не присутствует в исходниках                       |
| ACC_ANNOTATION | 0x2000 | это аннотация                                                 |
| ACC_ENUM       | 0x4000 | это enum                                                      |

Наш тестовый класс объявлен публичным и финальным, поэтому access_flag = (0x0001 | 0x0010) = 0x0011.

Поля interfaces_count и fields_count будут равны 0x0000, т.к класс Test не имеет ни интерфейсов, ни
полей класса. А массивы interfaces и fields будут пустыми.

## Constant pool

Специальная таблица хранящая в себе константы, на которые ссылаются остальные части class-файла.

## this_class

Данное поле содержит в себе индекс в constant pool, где лежит структура типа

```
CONSTANT_Class_info {
    u1 tag;
    u2 name_index;
}
```

содержащее описание текущего класса. Поле tag всегда равно значению 7. Поле name_index это индекс
в constant pool, где лежит структура типа

```
CONSTANT_Utf8_info {
    u1 tag;
    u2 length;
    u1 bytes[length];
}
```

, которая хранит в себе название данного класса. Поле tag в CONSTANT_Utf8_info всегда равно 1.
Поле length это длина строки в байтах. Поле bytes содержит непосредственно строку в виде байтов.

Наш класс называется Test. Для строки "Test" структура CONSTANT_Utf8_info будет выглядеть следующим
образом:

```
tag = 01 // для CONSTANT_Utf8_info всегда равно 1
length = 0004 // Строка Test в utf-8 это 4 байта
bytes = 54657374 // Байты в utf-8
```

или в виде hex-строки 01000454657374. А CONSTANT_Class_info для поля this_class будет выглядеть
следующим образом:

```
tag = 07 // для CONSTANT_Class_info всегда равно 7
name_index = 0001 // структуру для строки Test поместим в constant pool под индексом 1
```

В итоге в constant pool добавятся следующие записи

| constant pool index | value          | description                             |
| ---                 | ---            | ---                                     |
| 1                   | 01000454657374 | CONSTANT_Utf8_info для строки Test      |
| 2                   | 070001         | CONSTANT_Class_info для поля this_class |

А поле this_class в class-файле получит значение 0002.

## super_class

Данное поле содержит в себе индекс в constant pool, где лежит структура типа CONSTANT_Class_info
с описанием родителя нашего класса. Для класса Test это класс Object. Нужно будет повторить
те же процедуры что и для поля this_class, только в этот раз в структуре CONSTANT_Utf8_info
будет строка "java/lang/Object". В результате всех манипуляций в constant pool появится две
новых записи

| constant pool index | value                                  | description                                    |
| ---                 | ---                                    | ---                                            |
| 3                   | 0100106a6176612f6c616e672f4f626a656374 | CONSTANT_Utf8_info для строки java/lang/Object |
| 4                   | 070003                                 | CONSTANT_Class_info для поля super_class       |

Поле super_class в итоге получит значение 0004.

## Методы класса

Класс Test имеет только один метод - main. Поэтому поле methods_count примет значение 0x0001. Массив methods
будет содержать одну структуру вида

```
method_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}
```

Поле access_flag это битовая маска из значений из следующей таблицы

| flag name        | value  | description                                    |
| ---              | ---    | ---                                            |
| ACC_PUBLIC       | 0x0001 |  метод объявлен как public                     |
| ACC_PRIVATE      | 0x0002 |  метод объявлен как private                    |
| ACC_PROTECTED    | 0x0004 |  метод объявлен как protected                  |
| ACC_STATIC       | 0x0008 |  статичный метод                               |
| ACC_FINAL        | 0x0010 |  метод объявлен как final                      |
| ACC_SYNCHRONIZED | 0x0020 |  метод объявлен с synchronized                 |
| ACC_BRIDGE       | 0x0040 |  bridge метод сгенерированный компилятором     |
| ACC_VARARGS      | 0x0080 |  метод с varargs                               |
| ACC_NATIVE       | 0x0100 |  метод объявлен как native                     |
| ACC_ABSTRACT     | 0x0400 |  метод объявлен как abstract                   |
| ACC_STRICT       | 0x0800 |  метод объявлен с strictfp                     |
| ACC_SYNTHETIC    | 0x1000 |  synthetic метод; не присутствует в исходниках |


Класс Test содержит только один метод main который объявлен как public static.
access_flag будет равен (0x0001 | 0x0008) = 0x0009.

name_index - это индекс в constant pool, который содержит уже знакомую структуру CONSTANT_Utf8_info
с именем метода. Для строки "main" эта структура будет выглядеть как

```
tag = 01 // для CONSTANT_Utf8_info всегда равно 1
length = 0004 // Строка main в utf-8 это 4 байта
bytes = 6d61696e // Байты в utf-8
```

или в виде hex-строки 0100046d61696e. Эту структуру надо добавить в constant pool

| constant pool index | value          | description                             |
| ---                 | ---            | ---                                     |
| 5                   | 0100046d61696e | CONSTANT_Utf8_info для строки main      |

Поле name_index получит значение 0x0005.

Поле descriptor_index содержит индекс в constant pool, в котором хранится структура CONSTANT_Utf8_info
с описанием метода в формате ({аргументы метода}){возвращаемый тип}. Аргументы и возвращаемый тип метода
должны быть в специальном формате, который можно найти в сепцификации в разделе "4.3.3. Method Descriptors".
Для нашего примера {аргументы метода} будет строкой "[Ljava/lang/String;", а {возвращаемый тип} будет
строкой "V". Получается, что в CONSTANT_Utf8_info должна хранится строка "([Ljava/lang/String;)V"

```
tag = 01 // для CONSTANT_Utf8_info всегда равно 1
length = 0016 // Строка ([Ljava/lang/String;)V в utf-8 это 22 байта
bytes = 285b4c6a6176612f6c616e672f537472696e673b2956 // Байты в utf-8
```

или в ввиде hex-строки 010016285b4c6a6176612f6c616e672f537472696e673b2956. В constant pool появится
новая запись

| constant pool index | value                                              | description                             |
| ---                 | ---                                                | ---                                     |
| 6                   | 010016285b4c6a6176612f6c616e672f537472696e673b2956 | CONSTANT_Utf8_info для descriptor_index |

Поле descriptor_index в итоге получит значение 0x0006

...

## Создание class-файла и его запуск

Если у вас установлена Java 17 и выше, то можно просто открыть jshell и выполнить следующие команды

```
String hexStr = "cafebabe00000034...0000"

java.nio.file.Files.write(java.nio.file.Paths.get("/tmp/Test.class"), java.util.HexFormat.of().parseHex(hexStr))

/exit
```

и затем запустить

```
java -cp /tmp Test
```
