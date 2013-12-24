	$(function() {
				//menu
				$("ul.menu li").hover(function(){
					$(">ul:not(:animated)",this).slideDown("fast");
				},
				function(){$(">ul",this).slideUp("fast");
				});
				//$("table.sortable tbody tr").mouseover(function(){$(this).addClass("hover");}).mouseout(function(){$(this).removeClass("hover");});
		});
		var straz = 'abcdefghijklmnopqrstuvwxyz'
		var strAZ = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
		function chktext_azToAZ(oj) {
			var newStr = ''
			for (i=0;i<oj.value.length;i++){
				if (straz.indexOf(oj.value.charAt(i)) != -1) 
					newStr += strAZ.charAt(straz.indexOf(oj.value.charAt(i)))
				else
					newStr += oj.value.charAt(i)
			}
			oj.value = newStr
		}
		function chktext_AZToaz(oj) {
			var newStr = ''
			for (i=0;i<oj.value.length;i++){
				if (strAZ.indexOf(oj.value.charAt(i)) != -1) 
					newStr += straz.charAt(strAZ.indexOf(oj.value.charAt(i)))
				else
					newStr += oj.value.charAt(i)
			}
			oj.value = newStr
		}
		function delspace(oj) {
			 var ojvalue = oj.value ;
			oj.value    = ojvalue.split(' ').join('').split('　').join('');
		}
		function check_gene_id(oj) {
			chktext_AZToaz(oj);
			delspace(oj);
		}
		var count;
		var main_gene_id;
		function BoxChecked(check,f){
			for(count = 0; count < f.elements.length; count++){
				if(f.elements[count].type =='hidden' && f.elements[count].id =='main_gene_id'){
					main_gene_id = "gene_id_" + f.elements[count].value;
//					alert("id :"+f.elements[count].id+"/value :"+f.elements[count].value+"/type :"+f.elements[count].type)
				}	
				if(f.elements[count].type =='checkbox'){
					f.elements[count].checked = check;	//チェックボックスをON/OFFにする
				}
			}
			//main_gene_id on
			if(!check){
				for(count = 0; count < f.elements.length; count++){
					if(f.elements[count].id ==main_gene_id){
						f.elements[count].checked = true;	//チェックボックスをON/OFFにする
					}	
				}
			}
		}	
		function BoxCheckedCnt(f){
			var selectCount=0;
			for(count = 0; count < f.elements.length; count++){
				if(f.elements[count].type =='checkbox' &&  f.elements[count].checked ==true){
					selectCount++;
				}
			}
//			alert("selectCount :"+selectCount);
			if(selectCount>10){
				alert("A maximum of ten gene_id can be checked.");
						return false;
			}else {
						return true;
			}
		}
