{
module Fred where
}

%name parser
%tokentype { () }
%token '*' { () }

%%

S : '*' { $1 }

{
main = putStrLn "Hello, I am Fred!"

happyError = undefined
}
