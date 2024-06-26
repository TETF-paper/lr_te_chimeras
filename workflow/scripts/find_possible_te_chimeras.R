library(Rsamtools)
library(tidyverse)

bf <- Rsamtools::BamFile(ifelse(exists("snakemake"),snakemake@input$bam,"results/minimap2/embryo18_20hrs_1DONP_1.sorted.bam"))

p1 <- ScanBamParam(what=c("rname"),tag = "SA")
res1 <- scanBam(bf, param=p1)

tx <- res1[[1]][[1]]
tags <- res1[[1]][2][["tag"]][["SA"]]

stopifnot(length(tx) == length(tags))
  
dat <- tibble(tx=as.character(tx),SA=tags) |>
  drop_na() |>
  mutate(SA = map(SA,~str_split_1(.x,";(?=[[:word:]])")))

dat2 <- dat |> unnest(SA) |>
  mutate(SA = str_extract(SA,".+?(?=,)")) |>
  distinct() |>
  filter(xor(str_detect(tx,"FBtr"),str_detect(SA,"FBtr"))) |>
  mutate(aligned = map2(tx,SA,~{
    z=c(.x,.y);
    c(z[which(str_detect(z,"FBtr"))],
      z[which(!str_detect(z,"FBtr"))])
    })) |>
  unnest_wider(aligned,names_sep = "seq") |>
  dplyr::select(tx_id=alignedseq1,te=alignedseq2)


ids <- read_tsv(ifelse(exists("snakemake"),snakemake@input$tsv,"resources/fbgn_fbtr_fbpp_expanded_fb_2024_02.tsv.gz"),skip=4) |>
  dplyr::select(gene_id=gene_ID,gene_symbol,tx_id=transcript_ID) |>
  distinct()

dat3 <- dat2 |>
  left_join(ids) |>
  dplyr::select(gene_id,gene_symbol,te) |>
  distinct()
  
write_tsv(dat3,snakemake@output$tsv)
  
