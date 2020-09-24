The correspondence of Cardinal Richelieu was last compiled in the 19th century by M. Avenel (Paris: Imprimerie Impériale, 1853–1877). That collection is acknowledged to be incomplete and biased by historians and Richelieu biographers; underrepresented are letters held outside of France and letters from aristocratic women whose influence over events might not be fully understood. To remedy this, I have identified and photographed letters to and from Richelieu not included in the Avenel compilation at archives in France, the UK, and the US; most of these letters are in manuscript, some in early modern print. This website includes facsimiles of and TEI-encoded transcriptions of those letters. The TEI is searchable through, and converted into an easily readable format by, the California Digital Library's XTF platform. Once we have permanent hosting the website address will be available here. 

notes for building
----- --- --------
1. Run the program `splitter.xslt` with the main corpus document (`RichelieuArchive.xml`, which is a `<teiCorpus>`) as input. It writes out several dozen output files (one for each `<TEI>`) into the `xtf/data/` directory.
2. `cd xtf/bin/`
3. `time ./textIndexer -clean -index default` (Note that the “-clean” is not always necessary, sometimes `-incremental` will do.)
4. It may be necessary, depending on the server OS, to change ownership and permissions of the resulting index directory: `sudo chgrp -R TOMCAT ../index/  &&  sudo chmod -R g+w ../index/`, where TOMCAT is the name of the tomcat user (e.g. “tomcat8”).
