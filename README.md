### redz0mb1e
Altera DE1 Port of redz0mb1e project from fpgakuechle.

* (http://www.mikrocontroller.net/svnbrowser/redz0mb1e/)
* (https://www.mikrocontroller.net/articles/Retrocomputing_auf_FPGA)
* (http://abnoname.blogspot.de/2013/07/z1013-auf-fpga-portierung-fur-altera-de1.html)
* (http://www.robotrontechnik.de/html/forum/thwb/showtopic.php?threadid=9276&pagenum=1)

### Z1013 auf FPGA (Portierung für Altera DE1) - Original Text 2013
In diesem Beitrag möchte ich meine Arbeiten zur Portierung des Z1013 FPGA Ports auf ein Altera DE1 vorstellen.

Bei dem Z1013 Port handelt es sich um das Projekt von "FPGAküchle", welches einen Preis beim Mikrocontroller.net Wettbewerb gewonnen hat:

Retrocomputing auf FPGA (www.mikrocontroller.net)

Das Originalprojekt verwendet einen Xilinx Spartan 3E und implementiert folgende Komponenten:
* U880 CPU mit dem opensource Z80 kompatiblen T80 (http://opencores.org/project,t80)
* PIO
* Monitor EPROM
* RAM 
* VGA Controller VGARefComp (VGA%20RefComp.zip)
* PS2 Controller für Tastatureingaben

Für die meisten Retroportierungen existiert eigentlich immer eine Variante für das sog. Altera DE1 Board, welches sich als quasi Standard für deartige Projekte etabliert hat. Da ich ebenfalls ein DE1 besitze, lag ein Port für mich nahe :-)

Das Originalprojekt liegt in folgendem SVN Repository:
http://www.mikrocontroller.net/svnbrowser/redz0mb1e/

Für den Port auf Altera waren zunächst folgende Änderungen notwendig:
* PLL Anpassungen
* Prozessorregister waren abhängig von Xilinx RAM Zellen (T80_Reg) und wurden auf technologieunabhängige Logik umgebaut.
* Der VGA Ausgang des DE1 brauchte gegenüber dem Spartan Board invertierte Sync Signale.
* Der SRAM war FPGA intern mittels BRAM Blöcken realisiert. Das DE1 besitzt einen externen SRAM. Es erfolgt der Umbau auf externen 512kB SRAM.
* Im Originalprojekt wurde der interne SRAM mit Binärcode vorbelegt, welcher nach dem Start einen JUMP auf den Monitor ROM durchführt. Dadurch wurde im Original die ROM Suche durch NOPs übersprungen...
* ...Für den DE1 Port mit externem SRAM wurde dagegen auf eine Bootlogik umgebaut, welche vor dem ersten ROM - Zugriff den CPU Datenbus auf NULL hält, bis der Adressdecoder ein ROM - Select verlangt. Erst dann schaltet der Controller den Zugriff frei. Das ist in etwa die Methode, wie der Original Z1013 arbeitet.
* Mit einem Systemreset wird wieder in den Bootzustand geschaltet.

Etwa in der Zeit war dann das DDR Kleincomputertreffen in Garitz (KC Treffen 2013 in Garitz). Dort hatte ich durch Zufall einen Kollegen Bert (https://github.com/boert/Z1013-mist) kennen gelernt, der ebenfalls an einem FPGA Port arbeitet. Sein Ziel war ein KC85 auf FPGA Basis. Auf dem Treffen hatte er gleich den Port des Z1013 auf sein FPGA Board umgestrickt und wenige Tage später einen RS232 Loader implementiert, der dann auch gleich von mir in das Altera Projekt implementiert wurde.

Dafür waren folgende Erweiterungen notwendig:
* Datenbusmultiplexer für DMA Zugriff des RS232 Moduls
* Während des Speicherzugriffs per RS232 wird die T80 CPU auf RESET gehalten
* Nachdem Timeout des RS232 Moduls wartet jenes auf einen Binärstrom und lädt diesen direkt in den SRAM

Der Upload funktioniert z.B. unter Windows mittels Realterm (in diesem Falle sogar mit einem USB-RS232 Wandler von Profilic). Zum Test eignet sich z.B. Tinybasic.
