# Coral

<p align="center">
 <img src="docs/coral-logo.jpg" width="400" title="Coral Logo">
</p>

**Coral** é uma biblioteca para analisar, processar e reescrever visualizações definidas no Hive Metastore e compartilhá-las
em vários mecanismos de execução. Ele executa traduções SQL para permitir visualizações expressas em HiveQL (e potencialmente
outras linguagens) para serem acessíveis em mecanismos como [Trino (anteriormente PrestoSQL)](https://trino.io/),
[Apache Spark](https://spark.apache.org/) e [Apache Pig](https://pig.apache.org/).
Coral não apenas traduz definições de visão entre diferentes dialetos SQL/não SQL, mas também reescreve expressões para
produzir semanticamente equivalentes, levando em consideração a semântica da linguagem ou motor de destino.
Por exemplo, ele compõe automaticamente novas expressões internas que são equivalentes a cada expressão interna no
definição de exibição de origem. Além disso, integra-se com [Transport UDFs](https://github.com/linkedin/transport)
para habilitar a tradução e execução de funções definidas pelo usuário (UDFs) no Hive, Trino, Spark e Pig.Coral está 
em desenvolvimento ativo. Atualmente, estamos procurando expandir o conjunto de APIs de linguagem de visualização de entrada além do HiveQL,
e implementação de algoritmos de reescrita de consulta para governança de dados e otimização de consulta.

## <img src="https://user-images.githubusercontent.com/10084105/141652009-eeacfab4-0e7b-4320-9379-6c3f8641fcf1.png" width="30" title="Slack Logo"> Slack

- Participe da discussão com a comunidade no Slack [aqui](https://join.slack.com/t/coral-sql/shared_invite/zt-s8te92up-qU5PSG~spK33ovPPL5v96A)!

## Módulos

**Coral** consiste nos seguintes módulos:

- Coral-Hive: Converte definições de visualizações do Hive com UDFs para o plano lógico de visualização equivalente;
- Coral-Trino: Converte o plano lógico de visualização em Trino (anteriormente PrestoSQL) SQL e vice-versa;
- Coral-Spark: Converte o plano lógico de exibição em Spark SQL;
- Coral-Pig: Converte o plano lógico de visualização para Pig-latin;
- Coral-Schema: Deriva o esquema Avro de visão usando o plano lógico de visão e os esquemas Avro de entrada de tabelas base;
- Coral-Spark-Plan: Converte as strings do plano Spark em um plano lógico equivalente (em andamento);
- Coral-Service: Serviço que expõe APIs REST que permitem que os usuários interajam com o Coral (consulte [Coral-as-a-Service](##Coral-as-a-Service) para obter mais detalhes).

## Como construir

Clone the repository:

```bash
git clone https://github.com/linkedin/coral.git
```

Build:

```bash
./gradlew clean build
```

## Contribuindo

The project is under active development and we welcome contributions of different forms.
Please see the [Contribution Agreement](CONTRIBUTING.md).

## Recursos

- [Coral: A SQL translation, analysis, and rewrite engine for modern data lakehouses](https://engineering.linkedin.com/blog/2020/coral), LinkedIn Engineering Blog, 12/10/2020.
- [Coral & Transport UDFs: Building Blocks of a Postmodern Data Warehouse](https://www.slideshare.net/walaa_eldin_moustafa/coral-transport-udfs-building-blocks-of-a-postmodern-data-warehouse-229545076), Tech-talk, Facebook HQ, 2/28/2020.
- [Transport: Towards Logical Independence Using Translatable Portable UDFs](https://engineering.linkedin.com/blog/2018/11/using-translatable-portable-UDFs), LinkedIn Engineering Blog, 11/14/2018.
- [Dali Views: Functions as a Service for Big Data](https://engineering.linkedin.com/blog/2017/11/dali-views--functions-as-a-service-for-big-data), LinkedIn Engineering Blog, 11/9/2017.


## Coral-as-a-Service

**Coral-as-a-Service** ou simplesmente **Coral Service** é um serviço que expõe APIs REST que permitem que os usuários interajam com o Coral sem necessariamente vir de um mecanismo de computação. Atualmente, o serviço oferece suporte a uma API para tradução de consulta entre diferentes dialetos e outra para interagir com um Hive Metastore local para criar bancos de dados, tabelas e exibições de exemplo para que possam ser referenciados na API de tradução. O serviço pode ser usado em dois modos: modo Hive Metastore remoto e modo Hive Metastore local. O modo remoto usa um Hive Metastore existente (já implantado) para resolver tabelas e exibições, enquanto o modo local cria um Hive Metastore incorporado vazio para que os usuários possam adicionar suas próprias definições de tabela e exibição.

### Referência da API

#### /api/translations/translate
Uma API **POST** que recebe o corpo da solicitação JSON contendo os seguintes parâmetros e retorna a consulta traduzida:
- `fromLanguage`: Input dialect (e.g., spark, trino, hive -- see below for supported inputs)
- `toLanguage`: Output dialect (e.g., spark, trino, hive -- see below for supported outputs)
- `query`: SQL query to translate between two dialects

#### /api/catalog-ops/execute
Uma API **POST** que usa uma instrução SQL para criar um banco de dados/tabela/visualização no metastore local
(observação: este endpoint só está disponível com Coral Service no modo metastore local).

### Instruções para usar com exemplos
1. Clone [Coral repo](https://github.com/linkedin/coral)
```bash  
git clone https://github.com/linkedin/coral.git  
```  
2. No diretório raiz do Coral, acesse o módulo coral-service
```bash  
cd coral-service  
```  
3. Build
```bash  
../gradlew clean build  
```  
#### To run Coral Service using the **local metastore**:
4. Run
```bash  
../gradlew bootRun --args='--spring.profiles.active=localMetastore'  
```  
Example workflow using local metastore:

5. Create a database called `db1` in local metastore using the /api/catalog-ops/execute endpoint

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data "CREATE DATABASE IF NOT EXISTS db1" \
  http://localhost:8080/api/catalog-ops/execute

Creation successful
```
6. Create a table called `airport` within `db1` in local metastore using the /api/catalog-ops/execute endpoint

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data "CREATE TABLE IF NOT EXISTS db1.airport(name string, country string, area_code int, code string, datepartition string)" \
  http://localhost:8080/api/catalog-ops/execute

Creation successful
```

7. Translate a query on `db1.airport` in local metastore using the /api/translations/translate endpoint

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{
    "fromLanguage":"hive", 
    "toLanguage":"trino", 
    "query":"SELECT * FROM db1.airport"
  }' \
  http://localhost:8080/api/translations/translate
```
The translation result is:
```
Original query in hive: SELECT * FROM db1.airport
Translated to trino:
SELECT "name", "country", "area_code", "code", "datepartition"
FROM "db1"."airport"
```

#### To run Coral Service using the **remote metastore**:
4. Add your kerberos client keytab file to `coral-service/src/main/resources`
5. Appropriately replace all instances of `SET_ME` in `coral-service/src/main/resources/hive.properties`
6. Run
```  
../gradlew bootRun  
```  
7. Translate a query on existing table/view in remote metastore using the /translate endpoint

### Currently Supported Translation Flows
1. Hive to Trino
2. Hive to Spark
3. Trino to Spark  
   Note: During Trino to Spark translations, views referenced in queries are considered to be defined in HiveQL and hence cannot be used when translating a view from Trino. Currently, only referencing base tables is supported in Trino queries. This translation path is currently a POC and may need further improvements.
