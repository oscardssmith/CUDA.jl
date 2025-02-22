const uint64_t = UInt64
const uint32_t = UInt32

# outlined functionality to avoid GC frame allocation
@noinline function throw_api_error(res)
    if res == CUPTI_ERROR_OUT_OF_MEMORY
        throw(OutOfGPUMemoryError())
    else
        throw(CUPTIError(res))
    end
end

function check(f, errs...)
    res = retry_reclaim(in((CUPTI_ERROR_OUT_OF_MEMORY, errs...))) do
        f()
    end

    if res != CUPTI_SUCCESS
        throw_api_error(res)
    end

    return
end

macro CUPTI_PROFILER_STRUCT_SIZE(type, lastfield)
    type = esc(type)
    lastfield = QuoteNode(lastfield)
    quote
        $struct_size($type, $lastfield)
    end
end
