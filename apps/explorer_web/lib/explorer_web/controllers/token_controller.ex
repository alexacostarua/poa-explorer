defmodule ExplorerWeb.TokenController do
  use ExplorerWeb, :controller

  alias Explorer.Chain
  alias Explorer.Chain.{Token, TokenTransfer}

  import ExplorerWeb.Chain, only: [split_list_by_page: 1, paging_options: 1, next_page_params: 3]

  def show(conn, %{"id" => address_hash_string} = params) do
    with {:ok, address_hash} <- Chain.string_to_address_hash(address_hash_string) do
      token = Token.token_from_address(address_hash)

      transfers_plus_one = TokenTransfer.fetch_token_transfers(address_hash, paging_options(params))

      {transfers, next_page} = split_list_by_page(transfers_plus_one)

      render(
        conn,
        "show.html",
        transfers: transfers,
        token: token,
        total_token_transfers: TokenTransfer.count_token_transfers(address_hash),
        total_address_in_token_transfers: TokenTransfer.count_addresses_in_transfers(address_hash),
        next_page_params: next_page_params(next_page, transfers, params)
      )
    else
      :error ->
        not_found(conn)

      {:error, :not_found} ->
        not_found(conn)
    end
  end
end
