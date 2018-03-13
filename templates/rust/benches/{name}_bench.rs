#[macro_use] extern crate bencher;
extern crate {name};

use bencher::Bencher;
use {name}::{Name};

fn benchmark_hello(bench: &mut Bencher) {
    bench.iter(|| {
        {Name}::hello();
    })
}

benchmark_group!(
    benches,
    benchmark_hello
);

benchmark_main!(benches);
