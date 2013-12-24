#require 'rubygems'
#require 'gruff'

class ProteinsController < ApplicationController

layout 'proteins', :except => [ :top,  :help_geneId]

################################
#メニュー→一覧表示
################################
	def list_protein
		@material			=		Material.find(params[:material_id])
		@list_protein		=		Msresult.where('material_id =:material_id AND gel_no=1',:material_id =>params[:material_id].to_i)
	end

##################################
#一覧表示（検索条件指定 search_gene_id）
##################################
	def search_list_protein_by_gene_id
		@list_protein			=		Array.new
		@search_gene_id	=		params[:search_gene_id]
		protein 				=		Protein.find_by_search_gene_id(@search_gene_id)

		if protein !=nil then
			@list_protein	=	Msresult.where('gene_id = :gene_id AND material_id =:material_id AND gel_no=1',:gene_id => protein.gene_id,:material_id =>params[:material_id].to_i)
			@search_gene_id		=	protein.gene_id
		end

		@material			=		Material.find(params[:material_id])
		render 'proteins/list_protein'
	end

######################################
#一覧表示（検索条件指定 symbols/description）
######################################
	def search_list_protein_by_symbols_or_description

		proteins			=	Protein.where('symbols like :symbols AND description like :description',:symbols =>  "%"+params[:symbols]+"%",:description =>  "%"+params[:description]+"%")
		tmplist				=	Array.new
		proteins.each {|protein|
			tmplist.push(protein.gene_id)
		}
		@list_protein		=	Msresult.where('gene_id IN (:gene_id) AND material_id =:material_id AND gel_no=1',:gene_id => tmplist,:material_id =>params[:material_id].to_i)
		material			=	Material.find(params[:material_id])

		@search_symbols			=	params[:symbols]
		@search_description		=	params[:description]
		@material						=	Material.find(params[:material_id])
		render 'proteins/list_protein'

	end	

################
#一覧表示→チャート
################
	def getchart
		xlist			=	Array.new
		ylist			=	Array.new
		wkeys		=	Array.new
		@gene_id_str	=	""
		
		#gene_list remake
		@main_gene_id	=	params[:main_gene_id]
		wkeys.push(@main_gene_id)

#@gene_id_str	= "ATCG00270,ATCG00280" 

		if	params[:gene_id_str].strip !=""  || params[:gene_id_str]!=nil  then
			@gene_id_str	= params[:gene_id_str]
			gene_id_arr	=		Array.new
			gene_id_arr	=		@gene_id_str.split(",")
			gene_id_arr.each {|w_gene_id|
				if(w_gene_id!=@main_gene_id)
					wkeys.push(w_gene_id)
				end
				}
		end

		
		#xlist, ylist make
		wkeys.each { |key|
			results		=	Msresult.find_all_by_material_id_and_gene_id(params[:material_id].to_i,key)

			wdataList = Array.new
			results.each {|result|
				#data
				if(params[:mode]=="1")
					wdataList.push(sprintf("%3.2f",result.empai).to_f)
				else
					wdataList.push(sprintf("%3.2f",result.empai_rt).to_f)
				end
				
				#label
				if(result.gene_id == @main_gene_id)
					xlist.push(result.gel_no.to_s)
				end
			}

			dataList =Array.new
			dataList [0] =key
			dataList [1] =wdataList
			ylist.push(dataList)
		 }
		#chart
		@graph= Lazychart.empai_chart(xlist,ylist,params[:mode])
		setheader(@main_gene_id,params[:material_id],params[:mode])
		render 'proteins/getchartslist'

	end
	
######################
#1チャート(複数)表示(select gel_no)
######################
def getchartlist
		xlist					=	Array.new
		ylist					=	Hash.new
		wdataList			=	Array.new
		dataList			=	Array.new
		wkeys				=	Array.new
		@gene_id_str	=	""

		@gel_no			=	params[:gel_no]

		#gene_list remake
		wkeys.push(params[:main_gene_id])

		if	params[:gene_id_str] !=""  || params[:gene_id_str]!=nil  then
			@gene_id_str	= params[:gene_id_str]
			gene_id_arr	=		Array.new
			gene_id_arr	=		@gene_id_str.split(",")
			gene_id_arr.each {|w_gene_id|
				if(w_gene_id!=params[:main_gene_id])
					wkeys.push(w_gene_id)
				end
				}
		end
	
		#list
		getlist(params[:main_gene_id],@gel_no,params[:material_id])
		
		#chart
		wkeys.each { |key|
			results		=	Msresult.find_all_by_material_id_and_gene_id(params[:material_id].to_i,key)

			#checkbox
			@msresults.each {|result|	
				if (result.gene_id == key)
					result.check=true
				end
			}

			wdataList = Array.new
			results.each {|result|
				#data
				if(params[:mode]=="1")
					wdataList.push(sprintf("%3.2f",result.empai).to_f)
				else
					wdataList.push(sprintf("%3.2f",result.empai_rt).to_f)
				end
				
				#label
				if(result.gene_id == params[:main_gene_id])
					xlist.push(result.gel_no.to_s)
				end
			}
			ylist =Hash.new
			ylist=[:name =>key,:data=>wdataList]
			dataList.push(ylist)
		 }
		makechart(xlist,dataList,params[:mode])

		#header
		setheader(params[:main_gene_id],params[:material_id],params[:mode])
		
		#weight
		@weights 		=   Materialweight.find_all_by_material_id(params[:material_id].to_i)

		render 'proteins/getchartslist'
#		render 'proteins/getchart'
end

####################################
#チャート複数表示(select gene_id.gel_no,mode)
####################################
def getchartslist
		xlist 					=		Array.new
		dataList			=		Array.new
		keys 					=		Hash.new
		wkeys				=		Array.new
		@gene_id_str	=		""

		#chart
		#gene_list remake
		wkeys.push(params[:main_gene_id])
		keys = params[:gene_id]

		keys.each {|key|
			if(key[1]==("1") && key[0]!=(params[:main_gene_id]))
				wkeys.push(key[0])
			end
		}
		@gene_id_str	=	wkeys.join(',')
		
		#list
		getlist(params[:main_gene_id],params[:gel_no],params[:material_id])	

		#Y軸
		wkeys.each {|key|
			results		=	Msresult.find_all_by_material_id_and_gene_id(params[:material_id].to_i,key)

			#checkbox
			@msresults.each {|result|	
				if (result.gene_id == key)
					result.check=true
				end
			}

			wdataList = Array.new
			results.each {|result|
				#data
				if(params[:mode]=="1")
					wdataList.push(sprintf("%3.2f",result.empai).to_f)
				else
					wdataList.push(sprintf("%3.2f",result.empai_rt).to_f)
				end
				
				#label
				if(result.gene_id == params[:main_gene_id])
					xlist.push(result.gel_no.to_s)
				end
			}
			ylist =Hash.new
			ylist=[:name =>key,:data=>wdataList]
			dataList.push(ylist)
		}
		makechart(xlist,dataList,params[:mode])

		#header
		setheader(params[:main_gene_id],params[:material_id],params[:mode])
		
		#weight
		@weights 		=   Materialweight.find_all_by_material_id(params[:material_id].to_i)

#		render 'proteins/getchartslist'
end

################
#内部Method(setHeader)
################
	def	setheader(w_main_gene_id,w_material_id,w_mode)
		#header
		@main_gene_id		=	w_main_gene_id
		@protein				=	Protein.find_by_gene_id(w_main_gene_id)
		@material				=	Material.find(w_material_id)
		#title
		@title		= ""
		@title.concat(w_main_gene_id)
		@title.concat(" [ ")
		@title.concat(@material	.material_name)
		@title.concat(" ] ")
		
		@mode					= w_mode

	end
################
#内部Method(getlist
################
	def  getlist(w_main_gene_id,w_gel_no,w_material_id)

		@msresults					=		Msresult.where('gel_no =:gel_no AND empai >0 AND material_id =:material_id',:gel_no =>w_gel_no,:material_id =>w_material_id.to_i).order('empai DESC')
		@selected_gel_no			=		w_gel_no
		@selected_gene_id		=		w_main_gene_id

	end
################
#内部Method
################
	def makechart(xlist,ylist,mode)

		if(mode=="1")
			y_title = "emPAI"
		else
			y_title = "emPAI ( % )"
		end

				@chart = Highchart.spline({
				:chart => {
					  :renderTo => "chart"
				},
				:title => {
#					:text => "Separation Profile"
                    :text => "Migration Profile"
				},
				:subtitle => {
					:text => '          '
				},
				:x_axis => {
                    :title => {
                        :text => "gel_slice_number"
                    },
					:tickInterval => 5,
					:tickWidth => 0,
					:gridLineWidth => 1,
					:categories => xlist,
					:labels => {
							:align => 'left',
							:x => 3,
							:y => -3 
						}
					},
				:y_axis => {
					:title => {
							:text => y_title						
						},
					:labels => {
							:align => 'left',
							:x => 3,
							:y => 16 
						},
					:showFirstLabel => false
					},
#					,{
#					:linkedTo => 0,
#					:gridLineWidth => 0,
#					:opposite => true,
#					:title => {
#						:text => 'emPAI'
#						}
#						:labels => {
#							:align => 'right',
#							:x => -3,
#							:y => 16
#						},
#						:showFirstLabel => false
#	
#					}],
				:legend => {
					:verticalAlign => 'top',
					:align => 'left',
					:y => 20,
					:floating => true,
					:borderWidth => 0
				},
				:tooltip => {
					:shared => true,
					:crosshairs => true,
#					:formatter => tooltip_formatter
				},
				:plotOptions => {
					:spline => {
						:cursor => 'pointer',
							:point => {
								:events => {
									:click => "function() {
										//document.gel_no_form.main_gene_id.value =this.series.name;
										document.gel_no_form.gel_no.value            =this.x+1;
										document.gel_no_form.action ='/proteins/getchartlist?main_gene_id='+document.gel_no_form.main_gene_id.value+'&gel_no='+document.gel_no_form.gel_no.value+'&material_id='+document.gel_no_form.material_id.value+'&mode='+document.gel_no_form.mode.value+'&gene_id_str='+document.gel_no_form.gene_id_str.value;
										showList();
									}"
								}
							}
					}
				},
				:series => ylist
			} )
	end
#######################
#メニュー→protein横断検索
#######################
	def key_protein
		@title ="search protein"
	end
#####################
#protein横断検索(gene_id特定)
#####################
	def search_protein
		@organism =0

		@msresults1	=Array.new
		@msresults2	=Array.new
		@msresults3	=Array.new
		@msresults4	=Array.new
		@msresults5	=Array.new
		@msresults6	=Array.new
		@msresults7	=Array.new
		@msresults8	=Array.new
		@msresults9	=Array.new
		@msresults10=Array.new
		@msresults11=Array.new
		@msresults12=Array.new
		@msresults13=Array.new
		@msresults14=Array.new
		@msresults15=Array.new
		@msresults16=Array.new
		@msresults17=Array.new
		@msresults18=Array.new
		@msresults19=Array.new
		@msresults20=Array.new
		@msresults21=Array.new
		@msresults22=Array.new
		@msresults23=Array.new
		@msresults24=Array.new
					
		@results1_exists	=	false
        @results2_exists	=	false
        @results3_exists	=	false
		@results4_exists	=	false
		@results5_exists	=	false
		@results6_exists	=	false
		@results7_exists	=	false
		@results8_exists	=	false
		@results10_exists	=	false
		@results11_exists	=	false
		@results12_exists	=	false
		@results13_exists	=	false
		@results14_exists	=	false
		@results15_exists	=	false
		@results16_exists	=	false
		@results17_exists	=	false
		@results18_exists	=	false
		@results19_exists	=	false
		@results20_exists	=	false
		@results21_exists	=	false
		@results22_exists	=	false
		@results23_exists	=	false
		@results24_exists	=	false
		
		keys 						=		Hash.new
		@arabi_homolog_flg=		false
		@arabi_homolog9_gene_id=""
		@arabi_homolog19_gene_id=""
		@arabi_homolog22_gene_id=""
		
		@arabi_homolog13_gene_id=""
		@arabi_homolog14_gene_id=""
		@arabi_homolog15_gene_id=""
		@arabi_homolog16_gene_id=""
		@arabi_homolog17_gene_id=""
		@arabi_homolog20_gene_id=""
		@arabi_homolog23_gene_id=""
		@arabi_homolog24_gene_id=""
		
		#header
		if params[:search_gene_id] !=nil then
			@protein = Protein.find_by_search_gene_id(params[:search_gene_id])
		else
			@protein = Protein.find_by_gene_id(params[:gene_id])
		end


		#organism 判定
		if @protein !=nil then
			@organism = @protein.organism
			@title = @protein.gene_id
			#materialあり・なし判定(KeyList作成）
			ms_materials			=	Msresult.where('gene_id = :gene_id AND gel_no =1',:gene_id =>@protein.gene_id)
			ms_materials.each {|ms_material|
					keys[ms_material.material_id]	= @protein.gene_id
			}
print "#######"
print "arabi_homolog_flg0"
print params[:arabi_homolog_flg]
				
			#Homolog KeyList作成
			if params[:arabi_homolog_flg]=="true" and @organism =1 then
				@arabi_homolog_flg=true
				
				homolog_proteins = Protein.find_all_by_arabi_gene_id(@protein.gene_id)
				homolog_proteins.each {|w_protein|
					homolog_materials		=	Msresult.where('gene_id = :gene_id AND gel_no =1',:gene_id =>w_protein.gene_id)
					homolog_materials.each {|homolog_material|
						keys[homolog_material.material_id]	= w_protein.gene_id
						if (homolog_material.material_id== 9) 
								@arabi_homolog9_gene_id=w_protein.gene_id
						elsif (homolog_material.material_id== 19) 
								@arabi_homolog19_gene_id=w_protein.gene_id
						elsif (homolog_material.material_id== 22) 
								@arabi_homolog22_gene_id=w_protein.gene_id
						elsif (homolog_material.material_id== 13) 
								@arabi_homolog13_gene_id=w_protein.gene_id
						elsif (homolog_material.material_id== 14) 
								@arabi_homolog14_gene_id=w_protein.gene_id
						elsif (homolog_material.material_id== 15) 
								@arabi_homolog15_gene_id=w_protein.gene_id
						elsif (homolog_material.material_id== 16) 
								@arabi_homolog16_gene_id=w_protein.gene_id
						elsif (homolog_material.material_id== 17) 
								@arabi_homolog17_gene_id=w_protein.gene_id
						 elsif (homolog_material.material_id== 20) 
								@arabi_homolog20_gene_id=w_protein.gene_id
						 elsif (homolog_material.material_id== 23) 
								@arabi_homolog23_gene_id=w_protein.gene_id
						 elsif (homolog_material.material_id== 24) 
								@arabi_homolog24_gene_id=w_protein.gene_id
						 end
					}
				}
			end 

	
			keys.each {|key|
			#organism =1の場合
            if(@organism ==1)
		            if( key[0] == 1)
						results1			=	Msresult.where('gene_id = :gene_id AND material_id =1',:gene_id =>key[1])
		               @results1_exists	=	true

		                results1_max				=0
		                results1.each {|result|
		                    if( result.empai  > results1_max)
		                        results1_max = result.empai 
		                    end
		                }

		                results1.each {|result|
		                    if( result.empai == 0)
		                        @msresults1.push("0")
		                    elsif( 0 < result.empai && result.empai <= results1_max / 3)
		                        @msresults1.push("1")
		                    elsif( results1_max / 3 < result.empai && result.empai <= results1_max * 2 / 3)
		                        @msresults1.push("2")
		                    else
		                        @msresults1.push("3")
		                    end
		                }
		             end

		            if( key[0]  == 2)
		                results2			=	Msresult.where('gene_id = :gene_id AND material_id =2',:gene_id =>key[1])
		               @results2_exists	=	true

		                results2_max				=0
		                results2.each {|result|
		                    if( result.empai  > results2_max)
		                        results2_max = result.empai 
		                    end
		                }

		                results2.each {|result|
		                    if( result.empai == 0)
		                        @msresults2.push("0")
		                    elsif( 0 < result.empai && result.empai <= results2_max / 3)
		                        @msresults2.push("1")
		                    elsif( results2_max / 3 < result.empai && result.empai <= results2_max * 2 / 3)
		                        @msresults2.push("2")
		                    else
		                        @msresults2.push("3")
		                    end
		                }
		             end

		            if( key[0] == 3)
		                 results3			=	Msresult.where('gene_id = :gene_id AND material_id =3',:gene_id =>key[1])
		                @results3_exists	=	true
		        
		                results3_max				=0
		                results3.each {|result|
		                    if( result.empai  > results3_max)
		                        results3_max = result.empai 
		                    end
		                }
		        
		                results3.each {|result|
		                    if( result.empai == 0)
		                        @msresults3.push("0")
		                    elsif( 0 < result.empai && result.empai <= results3_max / 3)
		                        @msresults3.push("1")
		                    elsif( results3_max / 3 < result.empai && result.empai <= results3_max * 2 / 3)
		                        @msresults3.push("2")
		                    else
		                        @msresults3.push("3")
		                    end
		                }
		            end


		            if( key[0] == 4)
		                results4			=	Msresult.where('gene_id = :gene_id AND material_id =4',:gene_id =>key[1])
		                @results4_exists	=	true
		        
		                results4_max				=0
		                results4.each {|result|
		                    if( result.empai  > results4_max)
		                       results4_max = result.empai 
		                    end
		                }
		        
		                results4.each {|result|
		                    if( result.empai == 0)
		                        @msresults4.push("0")
		                    elsif( 0 < result.empai && result.empai <= results4_max / 3)
		                        @msresults4.push("1")
		                    elsif( results4_max / 3 < result.empai && result.empai <= results4_max * 2 / 3)
		                        @msresults4.push("2")
		                   else
		                        @msresults4.push("3")
		                    end
		                }
		            end
		        

		            if( key[0] == 5)
		                results5			=	Msresult.where('gene_id = :gene_id AND material_id =5',:gene_id =>key[1])
		                @results5_exists	=	true
		        
		                results5_max				=0
		                results5.each {|result|
		                    if( result.empai  > results5_max)
		                        results5_max = result.empai 
		                    end
		                }
        
		                results5.each {|result|
		                    if( result.empai == 0)
		                        @msresults5.push("0")
		                    elsif( 0 < result.empai && result.empai <= results5_max / 3)
		                        @msresults5.push("1")
		                    elsif( results5_max / 3 < result.empai && result.empai <= results5_max * 2 / 3)
		                        @msresults5.push("2")
		                    else
		                        @msresults5.push("3")
		                    end
		                }
		            end

		            if( key[0] == 6)   
		                results6			=	Msresult.where('gene_id = :gene_id AND material_id =6',:gene_id =>key[1])
		                @results6_exists	=	true
        
		                results6_max				=0
		                results6.each {|result|
		                    if( result.empai  > results6_max)
		                        results6_max = result.empai 
		                    end
		                }
        
		                results6.each {|result|
		                    if( result.empai == 0)
		                        @msresults6.push("0")
		                    elsif( 0 < result.empai && result.empai <= results6_max / 3)
		                        @msresults6.push("1")
		                    elsif( results6_max / 3 < result.empai && result.empai <= results6_max * 2 / 3)
		                        @msresults6.push("2")
		                    else
		                        @msresults6.push("3")
		                    end
		                }

		            end
        

		            if( key[0] == 7) 
		                results7			=	Msresult.where('gene_id = :gene_id AND material_id =7',:gene_id =>key[1])
		                @results7_exists	=	true
        
		                results7_max				=0
		                results7.each {|result|
		                    if( result.empai  > results7_max)
		                        results7_max = result.empai 
		                    end
		                }

		                results7.each {|result|
		                    if( result.empai == 0)
		                        @msresults7.push("0")
		                    elsif( 0 < result.empai && result.empai <= results7_max / 3)
		                        @msresults7.push("1")
		                    elsif( results7_max / 3 < result.empai && result.empai <= results7_max * 2 / 3)
		                        @msresults7.push("2")
		                    else
		                        @msresults7.push("3")
		                    end
		                }
		            end
        

		            if( key[0]== 8) 
		                results8			=	Msresult.where('gene_id = :gene_id AND material_id =8',:gene_id =>key[1])
		                @results8_exists	=	true
        
		                results8_max				=0
		                results8.each {|result|
		                    if( result.empai  > results8_max)
		                        results8_max = result.empai 
		                    end
		                }
 
		                results8.each {|result|
		                    if( result.empai == 0)
		                        @msresults8.push("0")
		                    elsif( 0 < result.empai && result.empai <= results8_max / 3)
		                        @msresults8.push("1")
		                    elsif( results8_max / 3 < result.empai && result.empai <= results8_max * 2 / 3)
		                        @msresults8.push("2")
		                    else
		                        @msresults8.push("3")
		                    end
		                }

		            end
		            
		            if( key[0] == 10) 
		                results10			=	Msresult.where('gene_id = :gene_id AND material_id =10',:gene_id =>key[1])
		                @results10_exists	=	true
        
		                results10_max				=0
		                results10.each {|result|
		                    if( result.empai  > results10_max)
		                        results10_max = result.empai 
		                    end
		                }
 
		                results10.each {|result|
		                    if( result.empai == 0)
		                        @msresults10.push("0")
		                    elsif( 0 < result.empai && result.empai <= results10_max / 3)
		                        @msresults10.push("1")
		                    elsif( results10_max / 3 < result.empai && result.empai <= results10_max * 2 / 3)
		                        @msresults10.push("2")
		                    else
		                        @msresults10.push("3")
		                    end
		                }

		            end

		            if( key[0] == 11) 
		                results11			=	Msresult.where('gene_id = :gene_id AND material_id =11',:gene_id =>key[1])
		                @results11_exists	=	true
        
		                results11_max				=0
		                results11.each {|result|
		                    if( result.empai  > results11_max)
		                        results11_max = result.empai 
		                    end
		                }
		                results11.each {|result|
		                    if( result.empai == 0)
		                        @msresults11.push("0")
		                    elsif( 0 < result.empai && result.empai <= results11_max / 3)
		                        @msresults11.push("1")
		                    elsif( results11_max / 3 < result.empai && result.empai <= results11_max * 2 / 3)
		                        @msresults11.push("2")
		                    else
		                        @msresults11.push("3")
		                    end
		                }

		            end

					if( key[0] == 12) 
		                results12			=	Msresult.where('gene_id = :gene_id AND material_id =12',:gene_id =>key[1])
		                @results12_exists	=	true
        
		                results12_max				=0
		                results12.each {|result|
		                    if( result.empai  > results12_max)
		                        results12_max = result.empai 
		                    end
		                }
 
		                results12.each {|result|
		                    if( result.empai == 0)
		                        @msresults12.push("0")
		                    elsif( 0 < result.empai && result.empai <= results12_max / 3)
		                        @msresults12.push("1")
		                    elsif( results12_max / 3 < result.empai && result.empai <= results12_max * 2 / 3)
		                        @msresults12.push("2")
		                    else
		                        @msresults12.push("3")
		                    end
		                }
		            end

					if( key[0] == 18) 
		                results18			=	Msresult.where('gene_id = :gene_id AND material_id =18',:gene_id =>key[1])
		                @results18_exists	=	true
        
		                results18_max				=0
		                results18.each {|result|
		                    if( result.empai  > results18_max)
		                        results18_max = result.empai 
		                    end
		                }
 
		                results18.each {|result|
		                    if( result.empai == 0)
		                        @msresults18.push("0")
		                    elsif( 0 < result.empai && result.empai <= results18_max / 3)
		                        @msresults18.push("1")
		                    elsif( results18_max / 3 < result.empai && result.empai <= results18_max * 2 / 3)
		                        @msresults18.push("2")
		                    else
		                        @msresults18.push("3")
		                    end
		                }
		            end
		            
		            if( key[0] == 21) 
		                results21			=	Msresult.where('gene_id = :gene_id AND material_id =21',:gene_id =>key[1])
		                @results21_exists	=	true
        
		                results21_max				=0
		                results21.each {|result|
		                    if( result.empai  > results21_max)
		                        results21_max = result.empai 
		                    end
		                }
 
		                results21.each {|result|
		                    if( result.empai == 0)
		                        @msresults21.push("0")
		                    elsif( 0 < result.empai && result.empai <= results21_max / 3)
		                        @msresults21.push("1")
		                    elsif( results21_max / 3 < result.empai && result.empai <= results21_max * 2 / 3)
		                        @msresults21.push("2")
		                    else
		                        @msresults21.push("3")
		                    end
		                }
		            end
				
			end
			 #organism =2の場合
	
		            if( key[0] == 9) 
		                results9			=	Msresult.where('gene_id = :gene_id AND material_id =9',:gene_id =>key[1])
		                @results9_exists	=	true
		        		@arabi_homolog9_flg=true	 

		                results9_max				=0
		                results9.each {|result|
		                    if( result.empai  > results9_max)
		                        results9_max = result.empai 
		                    end
		                }
        
		                results9.each {|result|
		                    if( result.empai == 0)
		                        @msresults9.push("0")
		                    elsif( 0 < result.empai && result.empai <= results9_max / 3)
		                        @msresults9.push("1")
		                    elsif( results9_max / 3 < result.empai && result.empai <= results9_max * 2 / 3)
		                        @msresults9.push("2")
		                    else
		                        @msresults9.push("3")
		                    end
		                }
		            end
		            
		             if( key[0] == 19) 
		                results19			=	Msresult.where('gene_id = :gene_id AND material_id =19',:gene_id =>key[1])
		                @results19_exists	=	true
		                @arabi_homolog19_flg=true
		        
		                results19_max				=0
		                results19.each {|result|
		                    if( result.empai  > results19_max)
		                        results19_max = result.empai 
		                    end
		                }
        
		                results19.each {|result|
		                    if( result.empai == 0)
		                        @msresults19.push("0")
		                    elsif( 0 < result.empai && result.empai <= results19_max / 3)
		                        @msresults19.push("1")
		                    elsif( results19_max / 3 < result.empai && result.empai <= results19_max * 2 / 3)
		                        @msresults19.push("2")
		                    else
		                        @msresults19.push("3")
		                    end
		                }
		            end
		            
		             if( key[0] == 22) 
		                results22			=	Msresult.where('gene_id = :gene_id AND material_id =22',:gene_id =>key[1])
		                @results22_exists	=	true
		                @arabi_homolog22_flg=true
		        
		                results22_max				=0
		                results22.each {|result|
		                    if( result.empai  > results22_max)
		                        results22_max = result.empai 
		                    end
		                }
        
		                results22.each {|result|
		                    if( result.empai == 0)
		                        @msresults22.push("0")
		                    elsif( 0 < result.empai && result.empai <= results22_max / 3)
		                        @msresults22.push("1")
		                    elsif( results22_max / 3 < result.empai && result.empai <= results22_max * 2 / 3)
		                        @msresults22.push("2")
		                    else
		                        @msresults22.push("3")
		                    end
		                }
		            end

			#organism =3の場合
		            if( key[0] == 13) 
		                results13			=	Msresult.where('gene_id = :gene_id AND material_id =13',:gene_id =>key[1])
		                @results13_exists	=	true
		        		@arabi_homolog13_flg=true
		                results13_max				=0
		                results13.each {|result|
		                    if( result.empai  > results13_max)
		                        results13_max = result.empai 
		                    end
		                }
        
		                results13.each {|result|
		                    if( result.empai == 0)
		                        @msresults13.push("0")
		                    elsif( 0 < result.empai && result.empai <= results13_max / 3)
		                        @msresults13.push("1")
		                    elsif( results13_max / 3 < result.empai && result.empai <= results13_max * 2 / 3)
		                        @msresults13.push("2")
		                    else
		                        @msresults13.push("3")
		                    end
		                }
		            end

					#organism =4の場合
			        if( key[0] == 14) 
		                results14			=	Msresult.where('gene_id = :gene_id AND material_id =14',:gene_id =>key[1])
		                @results14_exists	=	true
		
		                results14_max				=0
		                results14.each {|result|
		                    if( result.empai  > results14_max)
		                        results14_max = result.empai 
		                    end
		                }
        
		                results14.each {|result|
		                    if( result.empai == 0)
		                        @msresults14.push("0")
		                    elsif( 0 < result.empai && result.empai <= results14_max / 3)
		                        @msresults14.push("1")
		                    elsif( results14_max / 3 < result.empai && result.empai <= results14_max * 2 / 3)
		                        @msresults14.push("2")
		                    else
		                        @msresults14.push("3")
		                    end
		                }
		            end

			#organism =5の場合

		            if( key[0] == 15) 
		                results15			=	Msresult.where('gene_id = :gene_id AND material_id =15',:gene_id =>key[1])
		                @results15_exists	=	true

		                results15_max				=0
		                results15.each {|result|
		                    if( result.empai  > results15_max)
		                        results15_max = result.empai 
		                    end
		                }
        
		                results15.each {|result|
		                    if( result.empai == 0)
		                        @msresults15.push("0")
		                    elsif( 0 < result.empai && result.empai <= results15_max / 3)
		                        @msresults15.push("1")
		                    elsif( results15_max / 3 < result.empai && result.empai <= results15_max * 2 / 3)
		                        @msresults15.push("2")
		                    else
		                        @msresults15.push("3")
		                    end
		                }
		            end


					#organism =6の場合
		            if( key[0] == 16) 
		                results16			=	Msresult.where('gene_id = :gene_id AND material_id =16',:gene_id =>key[1])
		                @results16_exists	=	true

		                results16_max				=0
		                results16.each {|result|
		                    if( result.empai  > results16_max)
		                        results16_max = result.empai 
		                    end
		                }
        
		                results16.each {|result|
		                    if( result.empai == 0)
		                        @msresults16.push("0")
		                    elsif( 0 < result.empai && result.empai <= results16_max / 3)
		                        @msresults16.push("1")
		                    elsif( results16_max / 3 < result.empai && result.empai <= results16_max * 2 / 3)
		                        @msresults16.push("2")
		                    else
		                        @msresults16.push("3")
		                    end
		                }
		            end
			

				#organism =7の場合
					if (key[0]  == 17)
						results17	=	Msresult.where('gene_id = :gene_id AND material_id =17',:gene_id =>key[1])

						@results17_exists			=true

						results17_max				=0
						results17.each {|result|
						if( result.empai  > results17_max)
							results17_max = result.empai 
						end
						}

			                results17.each {|result|
			                    if( result.empai == 0)
			                        @msresults17.push("0")
			                    elsif( 0 < result.empai && result.empai <= results17_max / 3)
			                        @msresults17.push("1")
			                    elsif( results17_max / 3 < result.empai && result.empai <= results17_max * 2 / 3)
			                        @msresults17.push("2")
			                    else
			                        @msresults17.push("3")
			                    end
			               }
					end

					#organism =8の場合
					if (key[0]  == 20)
						results20	=	Msresult.where('gene_id = :gene_id AND material_id =20',:gene_id =>key[1])

						@results20_exists			=true
						@arabi_homolog20_flg=true	        
						results20_max				=0
						results20.each {|result|
						if( result.empai  > results20_max)
							results20_max = result.empai 
						end
						}

			                results20.each {|result|
			                    if( result.empai == 0)
			                        @msresults20.push("0")
			                    elsif( 0 < result.empai && result.empai <= results20_max / 3)
			                        @msresults20.push("1")
			                    elsif( results20_max / 3 < result.empai && result.empai <= results20_max * 2 / 3)
			                        @msresults20.push("2")
			                    else
			                        @msresults20.push("3")
			                    end
			               }
					end
					#if key[0]  == 20
					
					#organism =9の場合
					if (key[0]  == 23)
						results23	=	Msresult.where('gene_id = :gene_id AND material_id =23',:gene_id =>key[1])

						@results23_exists			=true
						@arabi_homolog23_flg=true	        
						results23_max				=0
						results23.each {|result|
						if( result.empai  > results23_max)
							results23_max = result.empai 
						end
						}

			                results23.each {|result|
			                    if( result.empai == 0)
			                        @msresults23.push("0")
			                    elsif( 0 < result.empai && result.empai <= results23_max / 3)
			                        @msresults23.push("1")
			                    elsif( results23_max / 3 < result.empai && result.empai <= results23_max * 2 / 3)
			                        @msresults23.push("2")
			                    else
			                        @msresults23.push("3")
			                    end
			               }
					end
					#if key[0]  == 23
					
					#organism =10の場合
					if (key[0]  == 24)
						results24	=	Msresult.where('gene_id = :gene_id AND material_id =24',:gene_id =>key[1])

						@results24_exists			=true
						@arabi_homolog24_flg=true	        
						results24_max				=0
						results24.each {|result|
						if( result.empai  > results24_max)
							results24_max = result.empai 
						end
						}

			                results24.each {|result|
			                    if( result.empai == 0)
			                        @msresults24.push("0")
			                    elsif( 0 < result.empai && result.empai <= results24_max / 3)
			                        @msresults24.push("1")
			                    elsif( results24_max / 3 < result.empai && result.empai <= results24_max * 2 / 3)
			                        @msresults24.push("2")
			                    else
			                        @msresults24.push("3")
			                    end
			               }
					end
					#if key[0]  == 24

					
					
			}
			#keys.each {|key|
		else
		#if @protein !=nil then
			@title = params[:search_gene_id]
		end

  	end
    
################
#protein横断検索(gene_id非特定 symbols/description )
################
    def search_material_protein
        
        proteins   =Protein.where('symbols like :symbols AND description like :description',:symbols =>  "%"+params[:symbols]+"%",:description =>  "%"+params[:description]+"%")
        tmplist     =Array.new
        proteins.each {|protein|
            tmplist.push(protein.gene_id)
		}
        @msresults = Msresult.where('gene_id IN (:gene_id) AND gel_no=1',:gene_id => tmplist).select('DISTINCT gene_id,protein_id')       
    end 

#######################
#メニュー→protein複数指定
#######################
	def key_protein
		@title ="Single protein search"
	end

#######################
#メニュー→protein複数指定（material特定）
#######################
	def key_proteins
		@title ="Multiple protein search"
		@organisms=Organism.all
	end

#######################
#protein複数指定（material特定）
#######################
	def search_gene_list

		@msresults1	=Array.new
		@msresults2	=Array.new
		@msresults3	=Array.new
		@msresults4	=Array.new
		@msresults5	=Array.new
		@msresults6	=Array.new
		@msresults7	=Array.new
		@msresults8	=Array.new
		@msresults9	=Array.new
		@msresults10=Array.new

		@results1_exists	=	false
        @results2_exists	=	false
        @results3_exists	=	false
		@results4_exists	=	false
		@results5_exists	=	false
		@results6_exists	=	false
		@results7_exists	=	false
		@results8_exists	=	false
		@results10_exists	=	false
		@gene_id_str		=	""
		
		@title ="Multiple protein search result"

		@material			=	Material.find(params[:material_id])
		w_gene_id_str	=	params[:gene_id_list].gsub(/\r\n/,',').gsub(/\r/,',').gsub(/\n/,',')
#print "w_gene_id_str :"
#print w_gene_id_str
#print "\n"
		gene_id_arr	=	Array.new
		gene_id_arr	=	w_gene_id_str.split(",")
#print "gene_id_arr.length :"
#print gene_id_arr.length
#print "\n"
		@gene_list_len		=	gene_id_arr.length

		if(gene_id_arr.length >1 || gene_id_arr.length==1) then
#print "gene_id_arr[0] :"
#print gene_id_arr[0]
#print "\n"
			@protein1 = Protein.find_by_gene_id(gene_id_arr[0].strip)
			if @protein1 !=nil then
				results1			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein1.gene_id,:material_id=>params[:material_id])
				if results1.length >0 then
					 @results1_exists				=	true
					 @gene_id_str.concat(@protein1.gene_id)
					 @gene_id_str.concat(",")
		                results1_max				=0
		                results1.each {|result|
		                    if( result.empai  > results1_max)
		                        results1_max = result.empai 
		                    end
		                }
		                results1.each {|result|
		                    if( result.empai == 0)
		                        @msresults1.push("0")
		                    elsif( 0 < result.empai && result.empai <= results1_max / 3)
		                        @msresults1.push("1")
		                    elsif( results1_max / 3 < result.empai && result.empai <= results1_max * 2 / 3)
		                        @msresults1.push("2")
		                    else
		                        @msresults1.push("3")
		                    end
		                }
					end
				else
		     		@results1_err =gene_id_arr[0]
 			 end
		end
			
		if(gene_id_arr.length >2 || gene_id_arr.length==2) then
#print "gene_id_arr[1] :"
#print gene_id_arr[1]
#print "\n"
			@protein2 = Protein.find_by_gene_id(gene_id_arr[1].strip)
			if @protein2 !=nil then
					results2			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein2.gene_id,:material_id=>params[:material_id])
					if results2.length >0 then
						@results2_exists		=		true
						@gene_id_str.concat(@protein2.gene_id)
						@gene_id_str.concat(",")
		                results2_max				=0
		                results2.each {|result|
		                    if( result.empai  > results2_max)
		                        results2_max = result.empai 
		                    end
		                }
		                results2.each {|result|
		                    if( result.empai == 0)
		                        @msresults2.push("0")
		                    elsif( 0 < result.empai && result.empai <= results2_max / 3)
		                        @msresults2.push("1")
		                    elsif( results2_max / 3 < result.empai && result.empai <= results2_max * 2 / 3)
		                        @msresults2.push("2")
		                    else
		                        @msresults2.push("3")
		                    end
		                }
					end
				else
		 			@results2_err =gene_id_arr[1]
 			end
		end

		if(gene_id_arr.length >3 || gene_id_arr.length==3) then
#print "gene_id_arr[2] :"
#print gene_id_arr[2]
#print "\n"
			@protein3 = Protein.find_by_gene_id(gene_id_arr[2].strip)
			if @protein3 !=nil then
					results3			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein3.gene_id,:material_id=>params[:material_id])
					if results3.length >0 then
						@results3_exists		=		true
						@gene_id_str.concat(@protein3.gene_id)
						@gene_id_str.concat(",")
		                results3_max				=0
		                results3.each {|result|
		                    if( result.empai  > results3_max)
		                        results3_max = result.empai 
		                    end
		                }
		                results3.each {|result|
		                    if( result.empai == 0)
		                        @msresults3.push("0")
		                    elsif( 0 < result.empai && result.empai <= results3_max / 3)
		                        @msresults3.push("1")
		                    elsif( results3_max / 3 < result.empai && result.empai <= results3_max * 2 / 3)
		                        @msresults3.push("2")
		                    else
		                        @msresults3.push("3")
		                    end
		                }
					end
				else
		 			@results3_err =gene_id_arr[2]
 			end
		end
		
		if(gene_id_arr.length >4 || gene_id_arr.length==4) then
#print "gene_id_arr[3] :"
#print gene_id_arr[3]
#print "\n"
			@protein4 = Protein.find_by_gene_id(gene_id_arr[3].strip)
			if @protein4 !=nil then
					results4			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein4.gene_id,:material_id=>params[:material_id])
					if results4.length >0 then
						@results4_exists		=		true
						@gene_id_str.concat(@protein4.gene_id)
						@gene_id_str.concat(",")
		                results4_max				=0
		                results4.each {|result|
		                    if( result.empai  > results4_max)
		                        results4_max = result.empai 
		                    end
		                }
		                results4.each {|result|
		                    if( result.empai == 0)
		                        @msresults4.push("0")
		                    elsif( 0 < result.empai && result.empai <= results4_max / 3)
		                        @msresults4.push("1")
		                    elsif( results4_max / 3 < result.empai && result.empai <= results4_max * 2 / 3)
		                        @msresults4.push("2")
		                    else
		                        @msresults4.push("3")
		                    end
		                }
					end
				else
					@results4_err =gene_id_arr[3]
 			end
		end

		if(gene_id_arr.length >5 || gene_id_arr.length==5) then
#print "gene_id_arr[4] :"
#print gene_id_arr[4]
#print "\n"
			@protein5 = Protein.find_by_gene_id(gene_id_arr[4].strip)
			if @protein5 !=nil then
					results5			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein5.gene_id,:material_id=>params[:material_id])
					if results5.length >0 then
						@results5_exists		=		true
						@gene_id_str.concat(@protein5.gene_id)
						@gene_id_str.concat(",")
		                results5_max				=0
		                results5.each {|result|
		                    if( result.empai  > results5_max)
		                        results5_max = result.empai 
		                    end
		                }
		                results5.each {|result|
		                    if( result.empai == 0)
		                        @msresults5.push("0")
		                    elsif( 0 < result.empai && result.empai <= results5_max / 3)
		                        @msresults5.push("1")
		                    elsif( results5_max / 3 < result.empai && result.empai <= results5_max * 2 / 3)
		                        @msresults5.push("2")
		                    else
		                        @msresults5.push("3")
		                    end
		                }
					end
				else
		 			@results5_err =gene_id_arr[4]
 			end
		end

		if(gene_id_arr.length >6 || gene_id_arr.length==6) then
#print "gene_id_arr[5] :"
#print gene_id_arr[5]
#print "\n"
			@protein6 = Protein.find_by_gene_id(gene_id_arr[5].strip)
			if @protein6 !=nil then
					results6			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein6.gene_id,:material_id=>params[:material_id])
					if results6.length >0 then
						@results6_exists		=		true
						@gene_id_str.concat(@protein6.gene_id)
						@gene_id_str.concat(",")
		                results6_max				=0
		                results6.each {|result|
		                    if( result.empai  > results6_max)
		                        results6_max = result.empai 
		                    end
		                }
		                results6.each {|result|
		                    if( result.empai == 0)
		                        @msresults6.push("0")
		                    elsif( 0 < result.empai && result.empai <= results6_max / 3)
		                        @msresults6.push("1")
		                    elsif( results6_max / 3 < result.empai && result.empai <= results6_max * 2 / 3)
		                        @msresults6.push("2")
		                    else
		                        @msresults6.push("3")
		                    end
		                }
					end
				else
		 			@results6_err =gene_id_arr[5]
 			end
		end

		if(gene_id_arr.length >7 || gene_id_arr.length==7) then
#print "gene_id_arr[6] :"
#print gene_id_arr[6]
#print "\n"
			@protein7 = Protein.find_by_gene_id(gene_id_arr[6].strip)
			if @protein7 !=nil then
					results7			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein7.gene_id,:material_id=>params[:material_id])
					if results7.length >0 then
						@results7_exists		=		true
						@gene_id_str.concat(@protein7.gene_id)
						@gene_id_str.concat(",")
		                results7_max				=0
		                results7.each {|result|
		                    if( result.empai  > results7_max)
		                        results7_max = result.empai 
		                    end
		                }
		                results7.each {|result|
		                    if( result.empai == 0)
		                        @msresults7.push("0")
		                    elsif( 0 < result.empai && result.empai <= results7_max / 3)
		                        @msresults7.push("1")
		                    elsif( results7_max / 3 < result.empai && result.empai <= results7_max * 2 / 3)
		                        @msresults7.push("2")
		                    else
		                        @msresults7.push("3")
		                    end
		                }
					end
				else
		 			@results7_err =gene_id_arr[6]
 			end
		end

		if(gene_id_arr.length >8 || gene_id_arr.length==8) then
#print "gene_id_arr[7] :"
#print gene_id_arr[7]
#print "\n"
			@protein8 = Protein.find_by_gene_id(gene_id_arr[7].strip)
			if @protein8 !=nil then
					results8			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein8.gene_id,:material_id=>params[:material_id])
					if results8.length >0 then
						@results8_exists		=		true
						@gene_id_str.concat(@protein8.gene_id)
						@gene_id_str.concat(",")
		                results8_max				=0
		                results8.each {|result|
		                    if( result.empai  > results8_max)
		                        results8_max = result.empai 
		                    end
		                }
		                results8.each {|result|
		                    if( result.empai == 0)
		                        @msresults8.push("0")
		                    elsif( 0 < result.empai && result.empai <= results8_max / 3)
		                        @msresults8.push("1")
		                    elsif( results8_max / 3 < result.empai && result.empai <= results8_max * 2 / 3)
		                        @msresults8.push("2")
		                    else
		                        @msresults8.push("3")
		                    end
		                }
					end
				else
		 			@results8_err =gene_id_arr[7]
 			end
		end
		
		if(gene_id_arr.length >9 || gene_id_arr.length==9) then
#print "gene_id_arr[8] :"
#print gene_id_arr[8]
#print "\n"
			@protein9 = Protein.find_by_gene_id(gene_id_arr[8].strip)
			if @protein9 !=nil then
					results9			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein9.gene_id,:material_id=>params[:material_id])
					if results9.length >0 then
						@results9_exists		=		true
						@gene_id_str.concat(@protein9.gene_id)
						@gene_id_str.concat(",")
		                results9_max				=0
		                results9.each {|result|
		                    if( result.empai  > results9_max)
		                        results9_max = result.empai 
		                    end
		                }
		                results9.each {|result|
		                    if( result.empai == 0)
		                        @msresults9.push("0")
		                    elsif( 0 < result.empai && result.empai <= results9_max / 3)
		                        @msresults9.push("1")
		                    elsif( results9_max / 3 < result.empai && result.empai <= results9_max * 2 / 3)
		                        @msresults9.push("2")
		                    else
		                        @msresults9.push("3")
		                    end
		                }
					end
				else
		 			@results9_err =gene_id_arr[8]
 			end
		end
	
				if(gene_id_arr.length >10 || gene_id_arr.length==10) then
#print "gene_id_arr[9] :"
#print gene_id_arr[9]
#print "\n"
			@protein10 = Protein.find_by_gene_id(gene_id_arr[9].strip)
			if @protein10 !=nil then
					results10			=	Msresult.where('gene_id = :gene_id AND material_id =:material_id',:gene_id =>@protein10.gene_id,:material_id=>params[:material_id])
					if results10.length >0 then
						@results10_exists		=		true
						@gene_id_str.concat(@protein10.gene_id)
						@gene_id_str.concat(",")
		                results10_max				=0
		                results10.each {|result|
		                    if( result.empai  > results10_max)
		                        results10_max = result.empai 
		                    end
		                }
		                results10.each {|result|
		                    if( result.empai == 0)
		                        @msresults10.push("0")
		                    elsif( 0 < result.empai && result.empai <= results10_max / 3)
		                        @msresults10.push("1")
		                    elsif( results10_max / 3 < result.empai && result.empai <= results10_max * 2 / 3)
		                        @msresults10.push("2")
		                    else
		                        @msresults10.push("3")
		                    end
		                }
					end
				else
		 			@results10_err =gene_id_arr[9]
 			end
		end


	end
################
#ダウンロード
################
    def dawnload
        send_file("public/images/BN-MS_summary.xlsx")
    end
################
#メニュー→TOP画面
################
	def top
		render :layout => 'toph'

	end

################
#メニュー→Overview画面
################
	def overview
		#render :layout => 'proteins'
	end

################
#メニュー→Resources画面
################
	def resources
		#render :layout => 'proteins'
	end
    
################
#メニュー→About us画面
################
	def aboutus

	end
################
#Help
################
    def help_geneId
         render :layout => 'help'
    end

end

