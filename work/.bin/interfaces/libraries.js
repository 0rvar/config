// @flow

declare type fuzzy$BaseOptions = {
  pre: string,
  post: string,
  caseSensitive: boolean,
};
declare type fuzzy$FilterOptions<T> = fuzzy$BaseOptions & {
  extract: T => string,
};
declare type fuzzy$FilterResult<T> = {|
  string: string,
  original: T,
  index: number,
  score: number,
|};
declare type fuzzy$MatchResult = {|
  rendered: string,
  score: number,
|};
declare module 'fuzzy' {
  declare export function filter<T>(
    pattern: string,
    arr: Array<T>,
    options: $Shape<fuzzy$FilterOptions<T>>
  ): Array<fuzzy$FilterResult<T>>;
  declare export function match<T>(
    pattern: string,
    string: string,
    options: $Shape<fuzzy$BaseOptions>
  ): ?fuzzy$MatchResult;
  declare export default {
    filter: typeof filter,
    match: typeof match,
  };
}
