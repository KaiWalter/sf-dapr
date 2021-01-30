from dapr.ext.grpc import App, InvokeMethodRequest, InvokeMethodResponse
import os

for e in ['DAPR_HTTP_PORT', 'DAPR_GRPC_PORT']:
    print(f"{e}:{os.environ[e]}")

app = App()

@app.method(name='test')
def mymethod(request: InvokeMethodRequest) -> InvokeMethodResponse:
    print(request.metadata, flush=True)
    print(request.text(), flush=True)

    return InvokeMethodResponse(b'INVOKE_RECEIVED', "text/plain; charset=UTF-8")

app.run(50051)
