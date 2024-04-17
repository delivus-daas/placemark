export class TokenStorage {
  private static access: string | null = null;

  public static isAuthenticated(): boolean {
    return !!this.getToken();
  }

  public static storeToken(token: string): void {
    this.access = token;
  }

  public static clear(): void {
    this.access = "";
  }

  public static getToken(): string | null {
    if (this.access) return this.access;
    return null;
  }

}
