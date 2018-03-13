use super::*;

type Subject = {Name};

mod hello {
    use super::*;

    #[test]
    fn it_returns_hello_world() {
        assert_eq!(Subject::hello(), "Hello, world!");
    }
}
