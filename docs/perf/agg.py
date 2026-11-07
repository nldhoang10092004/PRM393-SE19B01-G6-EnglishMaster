import json,sys,statistics,glob
d=sys.argv[1]  # dir with <phase>.timeline_summary.json
b=[];r=[];mb=mr=0
for ph in ['home','cards','study']:
    j=json.load(open(f'{d}/{ph}.timeline_summary.json'))
    b+=[x/1000 for x in j['frame_build_times']]; r+=[x/1000 for x in j['frame_rasterizer_times']]
    mb+=j['missed_frame_build_budget_count']; mr+=j['missed_frame_rasterizer_budget_count']
    print(ph,j['frame_count'],round(j['average_frame_build_time_millis'],2),round(j['average_frame_rasterizer_time_millis'],2))
def p(a,q):
    a=sorted(a);return a[min(len(a)-1,int(q*len(a)))]
print(json.dumps(dict(frames=len(b),build_avg=round(statistics.mean(b),2),build_p90=p(b,.9),build_p99=p(b,.99),build_worst=max(b),missed_build=mb,
 raster_avg=round(statistics.mean(r),2),raster_p90=p(r,.9),raster_p99=p(r,.99),raster_worst=max(r),missed_raster=mr)))
