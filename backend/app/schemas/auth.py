from pydantic import BaseModel

class Login(BaseModel):
    email: str
    contrasena: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: str | None = None