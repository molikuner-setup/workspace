myZip :: [a] -> [b] -> [(a,b)]
myZip (a:as) (b:bs) = (a,b) : myZip as bs
myZip _ _           = []

zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' f (a:as) (b:bs) = f a b : zipWith' f as bs
zipWith' _ _ _           = []

zip' :: [a] -> [b] -> [(a,b)]
zip' = zipWith (\ a b -> (a,b))

combine :: (a -> b -> c) -> [a] -> [b] -> [c]
combine f as bs = [ f a b | a <- as, b <- bs ]

delete2 :: [a] -> [a]
delete2 (a:b:xs) = a : delete2 xs
delete2 xs       = xs

numbers :: [a] -> [(Int, a)]
numbers xs = zip' [0..length xs - 1] xs

delete2' :: [a] -> [a]
delete2' = map (snd) . filter (even . fst) . numbers

data Tree a = Nil
            | Node (Tree a) a (Tree a)

flatten :: Tree a -> [a]
flatten Nil            = []
flatten (Node t1 a t2) = flatten t1 ++ [a] ++ flatten t2

mapTree :: (a -> b) -> Tree a -> Tree b
mapTree _ Nil            = Nil
mapTree f (Node t1 a t2) = Node (mapTree f t1) (f a) (mapTree f t2)

foldTree :: (b -> a -> b -> b) -> b -> Tree a -> b
foldTree _ n Nil            = n
foldTree f n (Node t1 a t2) = f (foldTree f n t1) a (foldTree f n t2)

sumTree :: Num a => Tree a -> a
sumTree = foldTree (\ a -> (+) . (+) a) 0

flatten' :: Tree a -> [a]
flatten' = foldTree (\ a b c -> a ++ [b] ++ c) []

