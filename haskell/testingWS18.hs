data Tree a = Nil
            | Bin (Tree a) a (Tree a)
            deriving (Show)

foldT :: (b -> a -> b -> b) -> b -> Tree a -> b
foldT _ n Nil = n
foldT f n (Bin t1 a t2) = f (foldT f n t1) a (foldT f n t2)

mapT :: (a -> b) -> Tree a -> Tree b
mapT f = foldT (\ t1 a t2 -> Bin t1 (f a) t2) Nil

andT :: Tree Bool -> Bool
andT = foldT (\ a -> (&&) . (&&) a) True

orT :: Tree Bool -> Bool
orT = foldT (\ a -> (||) . (||) a) False

allT :: (a -> Bool) -> Tree a -> Bool
allT f = andT . mapT f

anyT :: (a -> Bool) -> Tree a -> Bool
anyT f = orT . mapT f

insert :: Ord a => a -> Tree a -> Tree a
insert x Nil = Bin Nil x Nil
insert x (Bin t1 a t2)
  | a < x = Bin t1 a (insert x t2)
  | a > x = Bin (insert x t1) a t2
  | otherwise = Bin t1 a t2

member :: Ord a => a -> Tree a -> Bool
member x = anyT ((==) x)

inv :: Ord a => Tree a -> Bool
inv Nil = True
inv (Bin t1 a t2) = allT ((>) a) t1 && allT ((<) a) t2 && inv t1 && inv t2

zipWithT :: (a -> b -> c) -> Tree a -> Tree b -> Tree c
zipWithT _ Nil _ = Nil
zipWithT _ _ Nil = Nil
zipWithT f (Bin t11 a t12) (Bin t21 b t22) = Bin (zipWithT f t11 t21) (f a b) (zipWithT f t12 t22)

filterT :: (a -> Bool) -> Tree a -> Tree a
filterT _ Nil = Nil
filterT f (Bin t1 a t2)
  | f a       = Bin (filterT f t1) a (filterT f t2)
  | otherwise = combine (filterT f t1) (filterT f t2)
  where
    combine :: Tree a -> Tree a -> Tree a
    combine Nil o = o
    combine o Nil = o
    combine (Bin t11 a t12) (Bin t21 b t22) = undefined -- TODO

fromList :: Ord a => [a] -> Tree a
fromList = foldr (insert) Nil

toList :: Tree a -> [a]
toList = foldT (\ xs a -> (++) (xs ++ [a])) []

safeHead :: Tree a -> Maybe a
safeHead Nil         = Nothing
safeHead (Bin _ a _) = Just a

size :: Tree a -> Int
size Nil = 0
size (Bin t1 _ t2) = 1 + (size t1) + (size t2)

smartFlatten :: Tree a -> [a]
smartFlatten = put []
  where
    put :: [a] -> Tree a -> [a]
    put xs Nil           = xs
    put xs (Bin t1 a t2) = put (a : put xs t2) t1


-- leftMost
-- rightMost

