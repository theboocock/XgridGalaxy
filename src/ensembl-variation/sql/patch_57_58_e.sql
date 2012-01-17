# add HGMD_MUTATION consequence to variation_feature
ALTER TABLE `variation_feature` CHANGE `consequence_type` `consequence_type` set('ESSENTIAL_SPLICE_SITE','STOP_GAINED','STOP_LOST','COMPLEX_INDEL','FRAMESHIFT_CODING','NON_SYNONYMOUS_CODING','SPLICE_SITE','PARTIAL_CODON','SYNONYMOUS_CODING','REGULATORY_REGION','WITHIN_MATURE_miRNA','5PRIME_UTR','3PRIME_UTR','INTRONIC','NMD_TRANSCRIPT','UPSTREAM','DOWNSTREAM','WITHIN_NON_CODING_GENE','NO_CONSEQUENCE','INTERGENIC','HGMD_MUTATION') NOT NULL DEFAULT 'INTERGENIC';

# add HGMD_MUTATION consequence to transcript_variation
ALTER TABLE `transcript_variation` CHANGE `consequence_type` `consequence_type` set('ESSENTIAL_SPLICE_SITE','STOP_GAINED','STOP_LOST','COMPLEX_INDEL','FRAMESHIFT_CODING','NON_SYNONYMOUS_CODING','SPLICE_SITE','PARTIAL_CODON','SYNONYMOUS_CODING','REGULATORY_REGION','WITHIN_MATURE_miRNA','5PRIME_UTR','3PRIME_UTR','INTRONIC','NMD_TRANSCRIPT','UPSTREAM','DOWNSTREAM','WITHIN_NON_CODING_GENE','NO_CONSEQUENCE','INTERGENIC','HGMD_MUTATION') NOT NULL DEFAULT 'INTERGENIC';

# patch identifier
INSERT INTO meta (species_id, meta_key, meta_value) VALUES (NULL,'patch', 'patch_57_58_e.sql|new consequence type HGMD_MUTATION');
