interface JwtToken {
    id: string,
    authority: [string],
    iat: number,
    exp: number,
    email: string,
    topic: string
}

export default JwtToken