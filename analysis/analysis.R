# analysis with sparql


library(SPARQL)
library(tidyverse)
library(ggplot2)

if(!require(devtools)) install.packages("devtools")
devtools::install_github("thomasp85/patchwork")

library(patchwork)
gesis <- "https://data.gesis.org/softwarekg/sparql"
res.overview <- SPARQL(url=gesis, 
              query= "select ?n ?y (count(?n) as ?count) 
              WHERE { 
              ?s rdf:type <http://schema.org/SoftwareApplication> .   
              ?s <http://schema.org/name> ?n . 
              ?m <http://data.gesis.org/softwarekg/software> ?s . 
              ?p <http://schema.org/mentions> ?m . 
              ?p <http://purl.org/dc/elements/1.1/date> ?y . 
              } 
              GROUP BY ?n ?y
              HAVING (count(?n) > 1)
ORDER by DESC(?count)")$results



# load from file
# res.overview <- read.csv2(file="data/queryOverview.csv", header=TRUE, sep=',')
length(unique(res.overview$n))

res.overview %>%
  dplyr::mutate(n=factor(n), y = as.integer(y)) %>%
  dim(.)


year2date <- function(y){
  as.Date(paste0(as.character(y),"-01-01"), "%Y-%m-%d")
}

res.overview %>%
  dplyr::mutate(n=factor(n), y = year2date(y))  %>%
  dplyr::group_by(n) %>%
  dplyr::mutate(s=sum(count)) %>%
  dplyr::ungroup() %>%
  dplyr::filter(s > 1690) ->
  res.overview
  
  
res.overview %>%
  dplyr::group_by(y) %>%
  dplyr::mutate(c2 = count/sum(count)) %>%
  dplyr::ungroup() %>%
  dplyr::filter(y>=year2date(2007)) %>%
  ggplot(. , aes(y,c2)) + 
    #geom_bar(aes(fill=n), stat = 'identity') +
    geom_line(aes(color=n)) +
    theme_minimal(base_size = 12) + 
    theme(legend.position = 'top') + 
    scale_x_date(breaks='year', date_labels = '%Y') + 
    xlab('year') + 
    ylab('Relative Frequency') +
    scale_color_brewer(name='Software', palette='Paired') +
    guides(color=guide_legend(nrow=2,byrow=TRUE)) ->
    p.relative
    
res.overview %>%
  dplyr::filter(y>=year2date(2007)) %>%
  ggplot(. , aes(y,count)) + 
  #geom_bar(aes(fill=n), stat = 'identity') + 
  geom_line(aes(color=n)) +
  xlab('year') + 
  ylab('Absolute Frequency') +
  scale_x_date(breaks='year', date_labels = '%Y') + 
  scale_color_brewer(palette='Paired') +
  theme_minimal(base_size = 12) + 
  theme(legend.position = 'none') ->
  p.absolute

p <- p.relative +  p.absolute + plot_layout(ncol = 1)
ggsave("software_counts_freq.png", p, dpi=1200)  
ggsave("software_counts.png", p.absolute, dpi=1200, width=10, height = 3)  

# plot wether application is available
query.free <- "select count(?n) as ?count ?free ?y 
              WHERE { 
              ?s rdf:type <http://schema.org/SoftwareApplication> . 
?s <http://data.gesis.org/softwarekg/freeAvailable> ?free .
              ?s <http://schema.org/name> ?n . 
              ?m <http://data.gesis.org/softwarekg/software> ?s . 
              ?p <http://schema.org/mentions> ?m . 
              ?p <http://purl.org/dc/elements/1.1/date> ?y . 
              } 
              GROUP BY ?y ?free"

res.free <- SPARQL(url = gesis, query = query.free)$results

#res.free <-  read.csv2(file="data/queryFree.csv", header=TRUE, sep=',')


query.source <- "select count(?n) as ?count ?source ?y 
              WHERE { 
              ?s rdf:type <http://schema.org/SoftwareApplication> . 
?s <http://data.gesis.org/softwarekg/sourceAvailable> ?source .
              ?s <http://schema.org/name> ?n . 
              ?m <http://data.gesis.org/softwarekg/software> ?s . 
              ?p <http://schema.org/mentions> ?m . 
              ?p <http://purl.org/dc/elements/1.1/date> ?y . 
              } 
              GROUP BY ?y ?source"

res.source <- SPARQL(url = gesis, query = query.source)$results
#res.source <- read.csv2(file="data/querySource.csv", header=TRUE, sep=',')

res.free %>% 
  dplyr::mutate(y = year2date(y), available='Free') %>%
  dplyr::filter(free == 'true') %>%
  dplyr::select(-free) ->
  free

res.free %>% 
  dplyr::mutate(y = year2date(y), available='Commercial') %>%
  dplyr::filter(free == 'false') %>%
  dplyr::select(-free) ->
  commercial


res.source %>% 
  dplyr::mutate(y = year2date(y), available='Source') %>%
  dplyr::filter(source == 'true') %>%
  dplyr::select(-source)->
  source
  
  
rbind(free, source, commercial) %>%
  ggplot(., aes(y,count)) + 
  geom_line(aes(color=available)) +
  xlab('year') + 
  ylab('Absolute Frequency') +
  scale_x_date(breaks='year', date_labels = '%Y') + 
  scale_color_brewer("Software availability", palette='Set1') +
  theme_minimal(base_size = 12) + 
  theme(legend.position = 'top') ->
  p.available

ggsave(filename = "open_free.png", p.available, width = 10, height = 3, dpi=1200)

query.topic <- "select ?n ?k (count(?n) as ?count)
WHERE {
?s rdf:type <http://schema.org/SoftwareApplication> .
?s <http://schema.org/name> ?n .
?m <http://data.gesis.org/softwarekg/software> ?s .
?p <http://schema.org/mentions> ?m .
?p <http://purl.org/dc/elements/1.1/date> ?y .
?p <http://schema.org/keywords> ?k .
}
GROUP BY ?n ?k
HAVING(count(?n) > 300)
ORDER BY DESC(?count)
"

res <- SPARQL(url = gesis, query = query.topic)

res$results %>%
  group_by(k) %>%
  mutate(c = count/sum(count)) %>%
  ggplot(., aes(k, n)) + 
  geom_tile(aes(fill=c)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  
  
  


query.software.with <- "select ?y (count(distinct ?p) as ?count)
WHERE {
?p <http://schema.org/mentions> ?m .
?m <http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#isString> ?a .
?p <http://purl.org/dc/elements/1.1/date> ?y .
?p rdf:type <http://schema.org/ScholarlyArticle> .
}
GROUP BY ?y"

res <- SPARQL(url = gesis, query = query.software.with)
w.software <- res$results

query.software.wo <- "select ?y (count(?p) as ?count)
WHERE {
?p rdf:type <http://schema.org/ScholarlyArticle> .
?p <http://purl.org/dc/elements/1.1/date> ?y .
}
GROUP BY ?y"

res <- SPARQL(url = gesis, query = query.software.wo)
wo.software <- res$results

dplyr::inner_join(wo.software, w.software, by='y') %>%
  mutate(r = count.y/count.x) %>%
  ggplot(., aes(y,r)) + 
  geom_line(group=1)





# replacement of software
query.openbugs <- "select ?y (count(?y) as ?count)
WHERE {
?s <http://schema.org/name> \"OpenBUGS\" .
?m <http://data.gesis.org/softwarekg/software> ?s .
?p <http://schema.org/mentions> ?m .
?p <http://purl.org/dc/elements/1.1/date> ?y .
}
GROUP BY ?y"

query.winbugs <- "select ?y (count(?y) as ?count)
WHERE {
?s <http://schema.org/name> \"WinBUGS\" .
?m <http://data.gesis.org/softwarekg/software> ?s .
?p <http://schema.org/mentions> ?m .
?p <http://purl.org/dc/elements/1.1/date> ?y .
}
GROUP BY ?y"

openbugs <- SPARQL(url = gesis, query = query.openbugs)$results
winbugs <-  SPARQL(url = gesis, query = query.winbugs)$results

#openbugs <- read.csv2(file="data/queryReplacement.csv", header=TRUE, sep=',')
#winbugs <- read.csv2(file="data/queryWinBUGS.csv", header=TRUE, sep=',')

openbugs$software <- "OpenBUGS"
winbugs$software <- "WinBUGS"

rbind(openbugs, winbugs) %>%
  dplyr::mutate(y = year2date(y)) %>%
  ggplot(., aes(y, count)) + 
    geom_line(aes(color=software, group=software)) +
  xlab('year') + 
  ylab('Absolute Frequency') +
  scale_x_date(breaks='year', date_labels = '%Y') + 
  scale_color_brewer(palette='Set1') +
  theme_minimal(base_size = 12) + 
  theme(legend.position = 'top') ->
  p.bugs

ggsave(filename = "BUGS_usage.png", p.bugs, width = 10, height = 3, dpi=1200)



query.replace <- "PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wds: <http://www.wikidata.org/entity/statement/>
PREFIX wdv: <http://www.wikidata.org/value/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX wikibase: <http://wikiba.se/ontology#>
PREFIX p: <http://www.wikidata.org/prop/>
PREFIX ps: <http://www.wikidata.org/prop/statement/>
PREFIX pq: <http://www.wikidata.org/prop/qualifier/>
PREFIX bd: <http://www.bigdata.com/rdf#>

select distinct ?software ?y (count(?y) as ?count) ?itemLabel ?item_s_1Label WHERE {{
?s rdf:type <http://schema.org/SoftwareApplication> .
?s <http://schema.org/name> ?software .
?s <http://schema.org/sameAs> ?link .
?m <http://data.gesis.org/softwarekg/software> ?s .
?p <http://schema.org/mentions> ?m .
?p <http://purl.org/dc/elements/1.1/date> ?y .
filter( regex(str(?link), \"wikidata\" ))}
{
SERVICE <https://query.wikidata.org/bigdata/namespace/wdq/sparql> {
?item p:P31/wdt:P279* ?item_s_0Statement .
?item_s_0Statement ps:P31/wdt:P279* wd:Q178285 .
?item p:P1366 ?item_s_1Statement .
?item_s_1Statement ps:P1366 ?item_s_1.
?item rdfs:label ?itemLabel.
FILTER(LANG(?itemLabel) = \"en\").
?item_s_1 rdfs:label ?item_s_1Label.
FILTER(LANG(?item_s_1Label) = \"en\").
OPTIONAL {?item wdt:P487 ?itemUnicodecharacter .}
OPTIONAL {?item wdt:P31 ?iteminstanceof .}
SERVICE wikibase:label { bd:serviceParam wikibase:language \"en\" . } }

}

bind(STRAFTER(str(?link), \"https://www.wikidata.org/wiki/\") as ?l1)
bind(STRAFTER(str(?item), \"http://www.wikidata.org/entity/\") as ?l2)
bind(STRAFTER(str(?item_s_1), \"http://www.wikidata.org/entity/\") as ?l3)

FILTER ( STR(?l1) = STR(?l2) || STR(?l1) = STR(?l3))
}

GROUP BY ?software ?y ?itemLabel ?item_s_1Label
ORDER by DESC(?y) "

data.replaced <- SPARQL(url = gesis, query = query.replace)$results

data.replaced %>%
  dplyr::mutate(y = year2date(y)) %>%
  ggplot(., aes(y, count)) + 
  geom_line(aes(color=software, group=software)) +
  xlab('year') + 
  ylab('Absolute Frequency') +
  scale_x_date(breaks='year', date_labels = '%Y') + 
  scale_color_brewer(palette='Set1') +
  theme_minimal(base_size = 12) + 
  theme(legend.position = 'top') ->
  p.replaced

ggsave(filename = "freeware.png", p.replaced, width = 10, height = 3, dpi=1200)


