takeLast :: Int -> [a] -> [a]
takeLast n xs = drop (length xs - n) xs

dropLast :: Int -> [a] -> [a]
dropLast n xs = take (length xs - n) xs

takeLast' :: Int -> [a] -> [a]
takeLast' n = reverse . take n . reverse

dropLast' :: Int -> [a] -> [a]
dropLast' n = reverse . drop n . reverse

-- takeLast should be more performant, as it goes through the whole list once. takeLast' in contrast goes through the list and the result list once.

-- seltsam :: Int -> [a] -> [a]
-- seltsam 3 [1..10] = [1..7]
-- seltsam should be the most performant, as it doesn't go through the whole list at all just through the resulting list which is always at max so long as the orig list

data Tree a = Nil
            | Bin (Tree a) a (Tree a)

leaf :: a -> Tree a
leaf a = Bin Nil a Nil

mapTree :: (a -> b) -> Tree a -> Tree b
mapTree _ Nil           = Nil
mapTree f (Bin t1 a t2) = Bin (mapTree f t1) (f a) (mapTree f t2)

allT :: (a -> Bool) -> Tree a -> Bool
allT _ Nil           = True
allT f (Bin t1 a t2) = f a && allT f t1 && allT f t2

insert :: Ord a => a -> Tree a -> Tree a
insert x Nil  = leaf x
insert x t@(Bin t1 a t2)
  | x < a     = Bin (insert x t1) a t2
  | x > a     = Bin t1 a (insert x t2)
  | otherwise = t

member :: Ord a => a -> Tree a -> Bool
member _ Nil  = False
member x (Bin t1 a t2)
  | x < a     = member x t1
  | x > a     = member x t2
  | otherwise = True

inv :: Ord a => Tree a -> Bool
inv Nil           = True
inv (Bin t1 a t2) = allT (<a) t1 && allT (>a) t2 && inv t1 && inv t2

fold :: (b -> a -> b -> b) -> b -> Tree a -> b
fold _ n Nil = n
fold f n (Bin t1 a t2) = f (fold f n t1) a (fold f n t2)

allT' :: (a -> Bool) -> Tree a -> Bool
allT' f = fold (\ ls a rs -> f a && ls && rs) True

toList :: Tree a -> [a]
toList = fold (\ ls a rs -> ls ++ (a : rs)) []

