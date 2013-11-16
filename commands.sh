echo
echo =================
echo download
echo =================
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.6.tar.gz

echo
echo =================
echo extract and get in
echo =================
tar zxf elasticsearch-0.90.6.tar.gz
cd elasticsearch-0.90.6

echo
echo =================
echo "make sure others don't join your cluster by accident:"
echo =================
echo '

discovery.zen.ping.multicast.enabled: false
discovery.zen.ping.unicast.hosts: ["localhost"]

'> config/elasticsearch.yml

echo
echo =================
echo start and wait for it to get started
echo =================
bin/elasticsearch
ERROR=1; while [ ! $ERROR -eq 0 ]; do sleep 1; curl localhost:9200; ERROR=$?; done

echo
echo =================
echo index a document
echo =================
curl -XPUT localhost:9200/blog/posts/1 -d '{
    "title": "Introduction to Elasticsearch"
}'

echo
echo =================
echo get it
echo =================
curl -XGET localhost:9200/blog/posts/1?pretty

echo
echo =================
echo update it
echo =================
curl -XPOST localhost:9200/blog/posts/1/_update -d '{
  "doc": {
    "tags": ["elasticsearch", "new york"]
  }
}'

echo
echo =================
echo get it again to see the changes
echo =================
curl -XGET localhost:9200/blog/posts/1?pretty

echo
echo =================
echo delete the document
echo =================
curl -XDELETE localhost:9200/blog/posts/1

echo
echo =================
echo delete its type
echo =================
curl -XDELETE localhost:9200/blog/posts

echo
echo =================
echo delete its index
echo =================
curl -XDELETE localhost:9200/blog

echo
echo =================
echo delete everything
echo =================
curl -XDELETE localhost:9200

echo
echo =================
echo URI search
echo =================
curl -XPUT localhost:9200/blog/posts/1 -d '{
    "title": "Introduction to Elasticsearch",
    "tags": ["elasticsearch", "new york"]
}'
curl localhost:9200/blog/_refresh
curl 'localhost:9200/blog/posts/_search?q=elasticsearch&pretty'

echo
echo =================
echo JSON search
echo =================
curl localhost:9200/_search?pretty -d '{
  "query": {
    "term": {
      "tags": "new"
    }
  }
}'

echo
echo =================
echo get mapping
echo =================
curl localhost:9200/blog/posts/_mapping?pretty

echo
echo =================
echo update mapping and reindex
echo =================
curl -XDELETE localhost:9200/blog/posts
curl -XPUT localhost:9200/blog/posts/_mapping -d '{
  "posts": {
    "properties": {
      "tags": {
        "type": "string",
        "index": "not_analyzed"
      }
    }
  }
}'
curl -XPUT localhost:9200/blog/posts/1 -d '{
    "title": "Introduction to Elasticsearch",
    "tags": ["elasticsearch", "new york"]
}'
curl localhost:9200/blog/_refresh
curl localhost:9200/_search?pretty -d '{
  "query": {
    "term": {
      "tags": "new york"
    }
  }
}'

echo
echo =================
echo facet
echo =================
curl -XPUT localhost:9200/blog/posts/2 -d '{
    "title": "Introduction to Hadoop",
    "tags": ["hadoop", "new york"]
}'
curl -XPOST localhost:9200/_refresh
curl localhost:9200/_search?pretty -d '{
  "facets": {
    "tags": {
      "terms": {
        "field": "tags"
      }
    }
  }
}'

echo
echo =================
echo "get & open Elasticsearch Head"
echo =================
git clone git://github.com/mobz/elasticsearch-head.git
firefox elasticsearch-head/index.html

echo
echo =================
echo "now we want others to join our cluster. Update config and restart"
echo =================
echo '

discovery.zen.ping.multicast.enabled: true

'> config/elasticsearch.yml
curl -XPOST localhost:9200/_shutdown
bin/elasticsearch
ERROR=1; while [ ! $ERROR -eq 0 ]; do sleep 1; curl localhost:9200; ERROR=$?; done

echo
echo =================
echo "create new index"
echo =================
curl -XPOST localhost:9200/users/ -d '{
  "settings": {
    "number_of_shards": 7
  }
}'

echo
echo =================
echo "change number of replicas"
echo =================
curl -XPUT localhost:9200/users/_settings -d '{
  "number_of_replicas": 0
}'

echo
echo =================
echo "show nodes stats"
echo =================
curl 'http://localhost:9200/_nodes/stats?pretty'