from fastapi import FastAPI
from pydantic import BaseModel
from click.testing import CliRunner
from lazarus_core.cli import cli  # Import the click entrypoint

app = FastAPI()

class BriefRequest(BaseModel):
    args: list[str] = []

@app.get("/")
def read_root():
    return {"message": "Lazarus Omega Brief Generator is operational. Submit a POST request to /brief to generate a brief."}

@app.post("/brief")
def generate_brief(request: BriefRequest):
    """
    Runs the lazarus-omega-brief command with the provided arguments.
    Example: {"args": ["--template", "A", "--output", "brief.txt"]}
    """
    runner = CliRunner()
    result = runner.invoke(cli, request.args, catch_exceptions=False)
    
    return {
        "output": result.output,
        "exit_code": result.exit_code
    }
