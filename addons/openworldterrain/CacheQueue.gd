extends Object


var pending = []
var mut_in
var sem


var callback
var name

func _init( name, instance, cb):
	self.name = name
	mut_in = Mutex.new()
	sem = Semaphore.new()

	callback = funcref( instance, cb )


func push(obj):
	var p = null
	mut_in.lock()
	p = pending.push_front(obj)
	print(name+" posted")
	sem.post()
	mut_in.unlock()


func process(thread):
	print(name+" waiting in thread %d" % thread)
	sem.wait()
	print(name+" notified in thread %d" % thread)
	
	var p = null
	while true :
		mut_in.lock()
		if (len(pending)==0):
			mut_in.unlock()
			break

		print(name +" count " +String(len(pending)))
		p = pending.pop_back()
		mut_in.unlock()
	
		print("call in thread %d" % thread)
		callback.call_func(p)
		print("ret in thread %d" % thread)
	
	
func find(o):
	if not len(pending):
		return false
		
	mut_in.lock()
	var res = (o in pending)
	mut_in.unlock()
	
	return res
	