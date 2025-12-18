

%.ps:%.fig
	fig2dev -L ps -l dummy -m 0.95 $< $@

%.eps:%.fig
	fig2dev -L eps $< $@

%.png:%.fig
	fig2dev -L png $< $@

#InFiles=$(shell echo  libvirt_arch_{1..4}.png)
#InFiles=$(shell find . -type f -name "libvirt_arch_[1-9].png")
PngFiles=$(shell find . -type f -name "libvirt_arch_[1-9].fig" | sed -e 's/fig/png/')
#f:
#	@echo $(InFiles)

all: testing.png repository_ctl.png final_arch.png ${PngFiles}

clean:
	rm -f *.fig.bak
	rm -f bbl_plan_1.eps bbl_plan_1.ps
	rm -f bbl_plan_found.ps 

