local Op = {}

function Op.add(m, a, b)
	for i = 1, a.r * a.c do
		m[i] = a[i] + b[i]
	end
	return m
end

function Op.scale(m, a, factor)
	m.r = a.r
	m.c = a.c
	for i = 1, a.r * a.c do
		m[i] = factor * a[i]
	end
	return m
end

return Op
