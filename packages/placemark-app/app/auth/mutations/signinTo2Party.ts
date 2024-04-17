import { resolver } from "@blitzjs/rpc";
import { Signin } from "../validations";
import { createSession } from "app/core/utils";
import { AuthenticationError } from "blitz";
import {TokenStorage} from "../../api/token.service";
import http from "../../api/http.service";

const CREDENTIALS_INVALID = "Sorry, those credentials are invalid.";

export const authenticateUser = async (
  rawEmail: string,
  rawPassword: string
) => {
    const email = rawEmail.toLowerCase().trim();
    const password = rawPassword.trim();

    try {
        let res = await http.post('/v1/auth/signin/', {username: email, password})
        TokenStorage.storeToken(res.data.access);
        res = await http.get('/v1/users/self/', {headers: {authorization: `Bearer ${res.data.access}`}})
        console.log("signin response", res)
        /**
         * Make all of this users memberships active
         */
        return res.data;
    }
    catch (error: any) {
        console.log("signin error", error)
        console.error(error)
        throw new AuthenticationError(CREDENTIALS_INVALID);
    }
};

export type UserForSession = Omit<
  Awaited<ReturnType<typeof authenticateUser>>,
  "createdAt" | "updatedAt" | "githubToken" | "walkthroughState"
>;

export default resolver.pipe(
  resolver.zod(Signin),
  async ({ email, password }, ctx) => {
    // This throws an error if credentials are invalid
    const user = await authenticateUser(email, password);
    await createSession(user, ctx);
    return user;
  }
);
