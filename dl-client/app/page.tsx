import { dehydrate, HydrationBoundary } from "@tanstack/react-query";
import { getPosts } from "./actions/sample";
import Posts from "./posts";
import { getQueryClient } from "@/app/providers/query-util";

export default async function Home() {
  const queryClient = getQueryClient();

  await queryClient.prefetchQuery({
    queryKey: ["posts"],
    queryFn: getPosts,
  });

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <Posts />
    </HydrationBoundary>
  );
}
