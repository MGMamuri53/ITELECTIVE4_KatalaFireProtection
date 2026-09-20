```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_payment', function (Blueprint $table) {
            $table->bigIncrements('v_paymentId');

            $table->unsignedBigInteger('v_orderId')
                ->nullable();

            $table->unsignedBigInteger('v_projectId')
                ->nullable();

            $table->unsignedBigInteger('v_customerId');

            $table->decimal('v_amount', 14, 2);

            $table->string('v_paymentMethod', 50)
                ->nullable();

            $table->string('v_paymentStatus', 50)
                ->nullable();

            $table->string('v_referenceNumber', 100)
                ->nullable();

            $table->dateTime('v_paymentDate')
                ->nullable();

            $table->unsignedBigInteger('v_verifiedByUserId')
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            // Order relationship
            $table->foreign(
                'v_orderId',
                'fk_payment_order'
            )
                ->references('v_orderId')
                ->on('tbl_order')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            // Project relationship
            $table->foreign(
                'v_projectId',
                'fk_payment_project'
            )
                ->references('v_projectId')
                ->on('tbl_project')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            // Customer relationship
            $table->foreign(
                'v_customerId',
                'fk_payment_customer'
            )
                ->references('v_customerId')
                ->on('tbl_customer')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            // Verified-by user relationship
            $table->foreign(
                'v_verifiedByUserId',
                'fk_payment_verifiedByUser'
            )
                ->references('v_userId')
                ->on('tbl_user')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });

        // PostgreSQL CHECK constraint must be added
        // AFTER the table has been created.
        //
        // A payment must belong to exactly ONE:
        // - order
        // - OR project
        DB::statement(
            'ALTER TABLE "tbl_payment"
             ADD CONSTRAINT "chk_payment_parent"
             CHECK (
                 ("v_orderId" IS NOT NULL AND "v_projectId" IS NULL)
                 OR
                 ("v_orderId" IS NULL AND "v_projectId" IS NOT NULL)
             )'
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_payment');
    }
};
