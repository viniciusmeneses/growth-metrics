module Reports
  module Records
    class AverageByMetricQuery < Micro::Case
      attribute :metric_id
      attribute :per, default: :day

      validates :metric_id, kind: Integer, allow_nil: true
      validates :per, kind: Symbol, inclusion: { in: [:minute, :hour, :day] }

      def call!
        grouped_records = Record
          .select(
            :metric_id,
            "MIN(records.timestamp) AS start_timestamp",
            "MAX(records.timestamp) AS end_timestamp",
            "SUM(records.value) AS total"
          )
          .group(:metric_id)
          .order(:metric_id)

        grouped_records = grouped_records.where(metric_id:) if metric_id.present?
        average = grouped_records.index_by(&:metric_id).transform_values { |record| calculate_average(record) }

        Success(result: { average: })
      end

      private

      def calculate_average(grouped_record)
        quantity = (grouped_record.end_timestamp - grouped_record.start_timestamp) / 1.send(per)
        grouped_record.total / (quantity.floor + 1)
      end
    end
  end
end
