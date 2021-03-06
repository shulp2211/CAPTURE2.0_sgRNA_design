# avoid dpnii cutting site when choosing target region for sgRNA design.

args = commandArgs(TRUE)
input_1 = args[1]
input_2 = args[2]
m = 70

peaks=read.table(paste(input_1,'.bed',sep=""),header=F,sep="\t")
dpnii=read.table(paste(input_2,'.bed',sep=""),header=F,sep="\t")
nearest_bed=matrix(NA,2*dim(peaks)[1],4)
min_dist=50
max_dist=100
for (i in 1:dim(peaks)[1]){
	print(i)
	dpnii_temp=dpnii[as.vector(dpnii[,1])==as.vector(peaks[i,1]),]
	up=as.vector(peaks[i,2])-as.vector(dpnii_temp[,3])  #peak start - dpnii end 
	up_min=min(up[up>0])
	nearest_bed_up=NULL
	if (up_min<min_dist){
		nearest_bed_up=c(as.vector(peaks[i,1]),peaks[i,2]-up_min,peaks[i,2]+min_dist-up_min,min_dist) # if dist from dpnii to peak start < 50, set it as 50.
	} else if ((up_min>=min_dist)&(up_min<=max_dist)){
		nearest_bed_up=c(as.vector(peaks[i,1]),peaks[i,2]-up_min,peaks[i,2],up_min)  # if dist from dpnii to peak start > =50 and <=100, use the dist.
	} else {
		nearest_bed_up=c(as.vector(peaks[i,1]),peaks[i,2]-max_dist,peaks[i,2],max_dist) # if dist from dpnii to peak start > 100, set it as 100.
	}
	
	down=as.vector(dpnii_temp[,2])-as.vector(peaks[i,3]) #dpnii start -  peak end
	down_min=min(down[down>0])
	nearest_bed_down=NULL
	if (down_min<min_dist){
		nearest_bed_down=c(as.vector(peaks[i,1]),peaks[i,3]-min_dist+down_min,peaks[i,3]+down_min,min_dist) # if dist from dpnii to peak end < 50, set it as 50.
	} else if ((down_min>=min_dist)&(down_min<=max_dist)){
		nearest_bed_down=c(as.vector(peaks[i,1]),peaks[i,3],peaks[i,3]+down_min,down_min) # if dist from dpnii to peak end >= 50 and <=100, use the dist.
	} else {
		nearest_bed_down=c(as.vector(peaks[i,1]),peaks[i,3],peaks[i,3]+max_dist,max_dist) # if dist from dpnii to peak end > 100, set it as 100.
	}
	nearest_bed[(2*i-1):(2*i),]=rbind(nearest_bed_up,nearest_bed_down)
}

nearest_bed[,4]=paste(nearest_bed[,1],":",nearest_bed[,2],"-",nearest_bed[,3],";",nearest_bed[,4],sep="")
for (i in 1:(ceiling(dim(nearest_bed)[1]/m))){
	nearest_bed_spe=nearest_bed[((i-1)*m+1):min(i*m,dim(nearest_bed)[1]),]
	write.table(nearest_bed_spe,paste(input_1,'_exclude_dpnii',i,'.bed',sep=""),col.names=F,row.names=F,sep="\t",quote=F)
}


