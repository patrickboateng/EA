

function soln = secant_method(x_0, x_1, fn, opts)
arguments
    x_0 {mustBeNumeric}
    x_1 {mustBeNumeric}
    fn {mustBeA(fn, "function_handle")}
    opts.TOL {mustBeFloat} = 1e-6
    opts.MAX_ITER {mustBeInteger} = 1000
end

x0 = x_0;
x1 = x_1;

idx = 1;
while idx < opts.MAX_ITER

    g_x1 = (fn(x1) - fn(x0)) / (x1 - x0);
    x2 = x1  - fn(x1) / g_x1;

    x0 = x1;
    x1 = x2;

    if abs(x1 - x0) < opts.TOL
        break
    end
    idx = idx + 1;
end
soln = x1;
end
