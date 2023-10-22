namespace qbinom {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    
    /// # Описание
    /// Реализация операции инкремента, то есть трансформации |k> -> |k+1>
    operation Inc(register: Qubit[]) : Unit is Ctl {
        let n = Length(register);
        for idx in 1..n {
            Controlled X(register[0..n-idx-1], register[n-idx]);
        }
    }

    /// # Описание
    /// Реализация операции суммирования, то есть трансформации |abcde...> -> |a+b+c+d+e+...>
    /// Это не самая эффективная реализация, но самая простая для кодирования
    operation Sum(qubits: Qubit[], register: Qubit[]) : Unit {
        for q in qubits {
            Controlled Inc([q], register);
        }
    }

    /// # Описание
    /// Реализация операции биноминального распределения, то есть n -> SUM SQRT(C(k,n))|k>
    operation Binom(n: Int, register: Qubit[]) : Unit {
        use qubits = Qubit[n] {
            ApplyToEach(H, qubits);
            Sum(qubits, register);
            ResetAll(qubits);
        }
    }

    @EntryPoint()
    operation Main() : Unit {
        Message("Hello quantum world!");

        // Параметры нашего примера
        let n = 10;
        let tests = 1000;


        let k = BitSizeI(n+1);
        use register = Qubit[k] {

            // Аллокируем массив для подсчёта количества исходов экспериментов
            mutable arr = [0, size = n + 1];

            // Повторям эксперимент несколько раз, с подсчётом колличества полученных исходов
            for _ in 1..tests {
                // Установим в register состояние SUM SQRT(C(k,n))|k>
                Binom(n, register); 

                // Для получения конкретного значения необходимо измерить значения кубиртов в регистре
                // и преобразовать полученный результат (вектор из |0> или |1>) в целое  число
                let results = ForEach(M, register);
                let i = ResultArrayAsInt(results);

                // Добавим полученное значение в счётчик
                set arr w/= i <- arr[i] + 1;

                // Очищаем кубиты после использования
                ResetAll(register);
            }

            // Выводим полученную таблицу частот 
            for s in arr {
                let p = 100 * s / tests;
                Message($"{p}%");
            }
        }
    }
}
