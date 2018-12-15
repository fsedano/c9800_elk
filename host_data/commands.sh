
#curl -H 'Content-type: application/json' -XPOST 'localhost:9200/shakespeare/doc/_bulk?pretty' --data-binary @shakespeare_6.0.json
#curl -H 'Content-type: application/json' -XPUT 'localhost:9200/shakespeare' --data-binary @shakes-mapping.json

curl -H 'Content-type: application/json' -XPUT 'localhost:9200/movies' -d '
    {
        "mappings" : {
            "movie" : {
                "properties" : {
                    "year" : {"type" : "date"}
                }
            }
        }
    }'

curl -H 'Content-type: application/json' -XPUT 'localhost:9200/movies/movie/109487' -d '
{
    "genre" : ["IMAX", "Sci-Fi"],
    "title" : "Interstellar",
    "year" : 2014
}'

curl -H 'Content-type: application/json' -XGET 'localhost:9200/movies/movie/_search?pretty'

wget http://media.sundog-soft.com/es/movies.json

curl -H 'Content-type: application/json' -XPUT 'localhost:9200/_bulk?pretty' --data-binary @ml-latest-small/movies.json

curl -H 'Content-type: application/json' -XPOST localhost:9200/movies/movie/109487/_update?version=10\&retry_on_conflict=10 -d '
{
    "doc" : {
        "title" : "Interstellar2"
    }
}
'

curl -H 'Content-type: application/json' -XDELETE 'localhost:9200/movies/movie/109487'

curl -H 'Content-type: application/json' -XGET 'localhost:9200/movies/movie/_search?pretty' -d '
{
    "query" : {
        "match" : {
            "title": "Star trek"
        }
    }
}
'

curl -H 'Content-type: application/json' -XPUT 'localhost:9200/movies' -d '
    {
        "mappings" : {
            "movie" : {
                "properties" : {
                    "id" : {"type" : "integer"},
                    "year" : {"type" : "date"},
                    "genre" : {"type" : "keyword"},
                    "title" : {"type": "text", "analyzer": "english"}
                }
            }
        }
    }'

wget http://media.sundog-soft.com/es/series.json

curl -H 'Content-type: application/json' -XDELETE 'localhost:9200/series'
curl -H 'Content-type: application/json' -XPUT 'localhost:9200/series' -d '
    {
        "mappings" : {
            "movie" : {
                "properties" : {
                    "film_to_franchise": { "type" : "join", "relations" : {"franchise" : "film"}}                }
            }
        }
    }'
curl -H 'Content-type: application/json' -XPUT 'localhost:9200/_bulk?pretty' --data-binary @series.json
curl -H 'Content-type: application/json' -XGET 'localhost:9200/movies/movie/_search?pretty' -d '
{
    "query" : {
        "match" : {
            "genre": "Sci-Fi"
        }
    }
}
'
