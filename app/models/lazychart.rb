# encoding: utf-8
class Lazychart

	def self.empai_chart(xlist,ylist,mode)
		if(mode=="1")
			y_title = "emPAI"
		else
			y_title = "emPAI ( % )"
		end

		@graph  = LazyHighCharts::HighChart.new('line_chart') do |f|
					#f.chart({ renderTo: 'chart'})
					f.title({ 
						text: 'Migration Profile'
						})
					f.xAxis({
						title: {
								text:'gel_slice_number'
						},
						tickInterval:5,
						tickWidth:	0,
						gridLineWidth:1,
						categories: xlist,
						labels: {
							align:'left',
							x:3,
							y:-3 
						}
					})
					f.yAxis({
						title: {
								text:y_title
						},
						labels: {
							align:'left',
							x:3,
							y:16
						},
						showFirstLabel: false
					})
					f.legend ({
						verticalAlign: 'top',
						align: 'left',
						y: 20,
						floating: true,
						borderWidth: 0
					})
					f.tooltip ({
						shared: true,
						crosshairs: true
					})
					f.plotOptions({
						spline: {
							cursor: 'pointer',
							point: {
								events: {
									click: %| function(){ alert('test'); } |.js_code
								}
							}
						}
					})
					ylist.each {|key|
						f.series( :name => key[0], :data => key[1])
					}
		end

	end

end
